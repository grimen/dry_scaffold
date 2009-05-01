require File.join(File.dirname(__FILE__), '..', 'dry_model', 'dry_model_generator')

class DmodelGenerator < DryModelGenerator
  
  def initialize(runtime_args, runtime_options = {})
    super
    # Make Rails look for templates within generator "dry_model" path
    @source_root = options[:source] || File.join(spec.path, '..', 'dry_model', 'templates')
  end
  
  def usage_message
    File.read(File.join(spec.path, '..', 'dry_model', 'USAGE')) rescue ''
  end
  
end