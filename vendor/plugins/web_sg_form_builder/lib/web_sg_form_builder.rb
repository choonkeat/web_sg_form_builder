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

class WebSgFormBuilder
  include ::ActionView::Helpers::TextHelper
  attr_accessor :builder
  
  def initialize(*args)
    @builder = ::ActionView::Helpers::FormBuilder.new(*args)
  end
  
  def fieldset(name, &proc)
    concat("<fieldset><legend>#{CGI.escapeHTML(name)}</legend><dl>", proc.binding)
    proc.call(self)
    concat("</dl></fieldset>", proc.binding)
  end

  def dd(label, hint = nil, &proc)
    concat("<dt><label>#{CGI.escapeHTML(label)}</label><span>#{CGI.escapeHTML(hint)}</span></dt><dd>", proc.binding)
    proc.call(self)
    concat("</dd>", proc.binding)
  end
  
  def method_missing(input_field, method, options = {}, *args)
    case input_field.to_s
    when /hidden/
      @builder.send(input_field, method, options, *args)
    when /check|radio/
      @builder.send(input_field, method, options, *args)
    when /submit|button/
      @builder.send(input_field, method, options, *args)
    else
      # select has extra argument before options hash
      opts = options.kind_of?(Hash) ? options : args.first
      label = opts.delete(:label) || method.to_s.humanize
      hint  = opts.delete :hint
      "<dt><label for=\"#{CGI.escapeHTML([@builder.object_name, method].join('_').downcase)}\"" + 
      ">#{CGI.escapeHTML(label)}</label><span>#{CGI.escapeHTML(hint)}</span></dt><dd" + 
      ">#{@builder.send(input_field, method, options, *args)}</dd>"
      end
  end
  
end
