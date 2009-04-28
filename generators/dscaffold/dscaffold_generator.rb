require File.join(File.dirname(__FILE__), '..', 'dry_scaffold', 'dry_scaffold_generator')

class DscaffoldGenerator < DryScaffoldGenerator
  
  def initialize(runtime_args, runtime_options = {})
    super
    # Make Rails look for templates within generator "dry_scaffold" path
    @source_root = options[:source] || File.join(spec.path, '..', 'dry_scaffold', 'templates')
  end
  
  def usage_message
    File.read(File.join(spec.path, '..', 'dry_scaffold', 'USAGE')) rescue ''
  end
  
end