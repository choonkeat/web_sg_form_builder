module WebSgFormHelper
  def form_for(name, *args, &proc)
    args.push({}) unless args.last.respond_to?(:merge)
    args.last.merge! :builder => WebSgFormBuilder
    super
  end
end
