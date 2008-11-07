# Striving to produce forms mark-up as such:
# 
# <form>
#   <fieldset>
#     <legend>Some Context</legend>
#     <dl>
#       <dt><label for="someid">Name</label></dt>
#       <dd><input id="someid" ... /></dd>
#     <dl>
#   </fieldset>
# <form>
require 'validated_attributes'

class WebSgFormBuilder
  include ::ActionView::Helpers::TextHelper
  attr_accessor :builder
  
  def initialize(*args)
    @builder = ::ActionView::Helpers::FormBuilder.new(*args)
  end
  
  def fieldset(name, &proc)
    concat("<fieldset><legend>#{name}</legend><dl>", proc.binding)
    proc.call(self)
    concat("</dl></fieldset>", proc.binding)
  end
  
  def dl(&proc)
    concat("<dl>", proc.binding)
    proc.call(self)
    concat("</dl>", proc.binding)
  end
  
  def dd(label, hint = nil, &proc)
    if proc
      concat("<dt><label class=\"dd\">#{label.to_s}</label> <span class=\"dd\">#{hint}</span></dt><dd>", proc.binding)
      proc.call(self)
      concat("</dd>", proc.binding)
    else
      "<dt><label>#{label.to_s.humanize}</label> <span>#{hint}</span></dt><dd>" +
      CGI.escapeHTML(@builder.object.send(label).to_s) +
      "</dd>"
    end
  end
  
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    label = options.delete(:label) || method.to_s.humanize
    field_id = CGI.escapeHTML([@builder.object_name, method].join('_').downcase)
    @builder.check_box(method, options, checked_value, unchecked_value) +
    " " +
    "<label class=\"check_box #{field_id} #{options[:label_class]}\" for=\"#{field_id}\"" +
    ">#{label}</label>"
  end
  
  def radio_button(method, tag_value, options = {})
    label = options.delete(:label) || tag_value.to_s.humanize
    field_id = CGI.escapeHTML([@builder.object_name, method, tag_value].join('_').downcase)
    @builder.radio_button(method, tag_value, options) +
    " " +
    "<label class=\"radio_button #{field_id} #{options[:label_class]}\" for=\"#{field_id}\"" +
    ">#{label}</label>"
  end
  
  def method_missing(input_field, *args)
    case input_field.to_s
    when /hidden|submit|button/
      @builder.send(input_field, *args)
    else
      if input_field.to_s =~ /=$/ || args.empty?
        @builder.send(input_field, *args)
      else
        # other tag helpers
        method = args.shift
        options = args.shift || {}
        # select has extra argument before options hash
        opts = options.kind_of?(Hash) ? options : args.first
        label = (opts.respond_to?(:delete) ? opts.delete(:label) : nil) || method.to_s.humanize
        hint  = (opts.respond_to?(:delete) ? opts.delete(:hint) : nil)
        label_class = (opts.respond_to?(:delete) ? opts.delete(:label_class) : nil)
        field_id = CGI.escapeHTML([@builder.object_name, method].join('_').downcase)
        "<dt><label class=\"#{input_field} #{field_id} #{label_class}\" for=\"#{field_id}\"" +
        ">#{label}</label> <span class=\"#{input_field} #{field_id} #{label_class}\">#{hint}</span></dt><dd" +
        ">#{@builder.send(input_field, method, options, *args)}</dd>"
      end
    end
  end
  
end
