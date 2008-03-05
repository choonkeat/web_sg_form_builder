module WebSgFormHelper
  def form_for(name, *args, &proc)
    unless args.empty?
      args.push({})  unless args.last.respond_to?(:merge)
      args.last.merge! :builder => WebSgFormBuilder
    end
    super
  end
  
  # Take effect if Rails 2
  def apply_form_for_options!(object_or_array, options)
    options.merge! :builder => WebSgFormBuilder
    super
  end
end
