module WebSgFormHelper
  # extracted from form_helper.rb:122
  def form_for(object_name, *args, &proc)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.last.is_a?(Hash) ? args.pop : {}
    
    # start modification
    options[:builder] ||= WebSgFormBuilder
    # end modification
    
    concat(form_tag(options.delete(:url) || {}, options.delete(:html) || {}), proc.binding)
    fields_for(object_name, *(args << options), &proc)
    concat('</form>', proc.binding)
  end
end
