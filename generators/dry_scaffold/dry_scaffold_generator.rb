class DryScaffoldGenerator < Rails::Generator::Base
  
  CONTROLLERS_PATH = File.join('app', 'controllers').freeze
  FUNCTIONAL_TESTS_PATH = File.join('test', 'functional').freeze
  HELPERS_PATH = File.join('app', 'helpers').freeze
  VIEWS_PATH = File.join('app', 'views').freeze
  MODELS_PATH = File.join('app', 'models').freeze
  
  RESOURCEFUL_COLLECTION_NAME = 'collection'.freeze
  RESOURCEFUL_SINGULAR_NAME = 'resource'.freeze
  
  PARTIALS = %w{form item}.freeze
  ACTIONS = %w{new edit show index}.freeze
  
  attr_reader :collection_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    
    @controller_name = @name.pluralize
    
    self.base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name = self.base_name.singularize
    
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions(self.controller_class_path, "#{self.controller_class_name}Controller", "#{self.controller_class_name}Helper")
      m.class_collisions(self.class_path, "#{self.class_name}")
      
      # Controllers
      m.directory File.join(CONTROLLERS_PATH, self.controller_class_path)
      controller_template = options[:skip_resourceful] ? 'standard' : 'inherited_resources'
      m.template "controller_#{controller_template}.rb",
        File.join(CONTROLLERS_PATH, self.controller_class_path, "#{self.controller_file_name}_controller.rb")
      
      # Functional Tests
      m.directory(File.join(FUNCTIONAL_TESTS_PATH, self.controller_class_path))
      m.template 'functional_test_standard.rb',
        File.join(FUNCTIONAL_TESTS_PATH, self.controller_class_path, "#{self.controller_file_name}_controller_test.rb")
      
      # Helpers
      m.directory(File.join(HELPERS_PATH, self.controller_class_path))
      m.template 'helper_standard.rb',
        File.join(HELPERS_PATH, self.controller_class_path, "#{self.controller_file_name}_helper.rb")
        
      # Views
      m.directory File.join(VIEWS_PATH, self.class_path)
      PARTIALS.each do |partial|
        m.template "view__#{partial}.html.haml",
          File.join(VIEWS_PATH, self.file_name, "#{partial}.html.haml"),
          :assigns => {:options => options}
      end
      ACTIONS.each do |action|
        m.template "view_#{action}.html.haml",
          File.join(VIEWS_PATH, self.file_name, "#{action}.html.haml"),
          :assigns => {:options => options}
      end
      
      # Routes
      m.route_resources self.controller_file_name
      
      # Models - use Rails default generator
      m.dependency 'model', [self.name] + @args, :collision => :skip
    end
  end
  
  protected
    
    def model_name
      class_name.demodulize
    end
    
    def assign_names!(name)
      super
      @collection_name = options[:skip_resourceful] ? @plural_name : RESOURCEFUL_COLLECTION_NAME
      @singular_name = options[:skip_resourceful] ? @singular_name : RESOURCEFUL_SINGULAR_NAME
      @plural_name = options[:skip_resourceful] ? @plural_name : RESOURCEFUL_SINGULAR_NAME.pluralize
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on('-r', '--skip-resourceful',
        "Generate generic 'inherited_resources' style URL names, i.e. collection_url, resource_url, etc. " +
        "Requires gem 'josevalim-inherited_resources'") do |v|
        options[:skip_resourceful] = v
      end
      opt.on('-f', '--skip-formtastic',
        "Generate semantic 'formtastic' style forms. Requires gem 'justinfrench-formtastic'") do |v|
        options[:skip_formtastic] = v
      end
    end
    
    def banner
      "Usage: #{$0} dry_scaffold ModelName [-r/--skip-resourceful] [-f/--skip-formtastic]"
    end
    
end
