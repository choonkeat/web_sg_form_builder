# 
# If we can easily inspect AST info (of blocks), this file
# can probably be obsoleted
# 
module ActiveRecord

  # 
  # Introducing a class-level, inheritable variable to 
  # store a hash of which attribute are validated by how, 
  # and with what error message
  #  
  class Base
    class_inheritable_accessor :validated_attributes
    @validated_attributes = {}
    def validation_info(key, attr_name)
      ((self.class.validated_attributes ? self.class.validated_attributes[key] : nil) || []).find {|arr, hash| arr.include? attr_name.to_sym }
    end
  end

  # 
  # When validation is declared by ActiveRecord classes,
  # record that down in our own hash
  # 
  module Validations
    module ClassMethods
      %w[validates_presence_of validates_format_of validates_numericality_of].each do |validates_X_of|
        err_message_key = case validates_X_of
        when /presence/
          :blank
        when /numericality/
          :not_a_number
        else
          :invalid
        end
        module_eval <<EOM
          def #{validates_X_of}_with_audit(*original_attr_names)
            meth = caller.first.split.last.gsub(/[^\w]+/, '')
            given_attr_names = original_attr_names.dup
            configuration = { :message => ActiveRecord::Errors.default_error_messages[:#{err_message_key}] }
            configuration.update(given_attr_names.pop) if given_attr_names.last.is_a?(Hash)            
            self.validated_attributes = (self.validated_attributes ? self.validated_attributes.dup : {})
            if self.validated_attributes[:#{validates_X_of}].kind_of? Array
              self.validated_attributes[:#{validates_X_of}] << [given_attr_names.collect{|s| s.to_sym}, configuration]
            else
              self.validated_attributes[:#{validates_X_of}] = [[given_attr_names.collect{|s| s.to_sym}, configuration]]
            end
            return #{validates_X_of}_without_audit(*original_attr_names)
          end
          alias_method_chain :#{validates_X_of}, :audit
EOM
      end
    end
  end
end
