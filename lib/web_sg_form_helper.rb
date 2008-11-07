module WebSgFormHelper
  def form_for(name, object = nil, options = {}, &proc)
    options = (options || {}).merge(:builder => WebSgFormBuilder)
    super
  end
end
