class DryScaffoldGenerator < Rails::Generator::NamedBase
  
  default_options :skip_resourceful => false, :skip_formtastic => false,
    :skip_tests => false, :skip_helpers => false, :skip_views => false
    
  CONTROLLERS_PATH = File.join('app', 'controllers').freeze
  HELPERS_PATH = File.join('app', 'helpers').freeze
  VIEWS_PATH = File.join('app', 'views').freeze
  MODELS_PATH = File.join('app', 'models').freeze
  FUNCTIONAL_TESTS_PATH = File.join('test', 'functional').freeze
  UNIT_TESTS_PATH = File.join('test', 'unit', 'helpers').freeze
  
  RESOURCEFUL_COLLECTION_NAME = 'collection'.freeze
  RESOURCEFUL_SINGULAR_NAME = 'resource'.freeze
  
  PARTIALS = %w{form item}.freeze
  ACTIONS = %w{new edit show index}.freeze
  
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :collection_name
                
  alias_method  :controller_file_name, :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    
    @controller_name = @name.pluralize
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name = base_name.singularize
    
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions "#{self.controller_class_name}Controller", "#{self.controller_class_name}ControllerTest"
      m.class_collisions "#{self.controller_class_name}Helper", "#{self.controller_class_name}HelperTest"
      m.class_collisions "#{self.class_path}", "#{self.class_name}"
      
      # Directories.
      m.directory File.join(CONTROLLERS_PATH, self.controller_class_path)
      m.directory File.join(HELPERS_PATH, self.controller_class_path) unless options[:skip_helpers]
      m.directory File.join(VIEWS_PATH, self.controller_class_path, self.controller_file_name.pluralize) unless options[:skip_views]
      m.directory File.join(FUNCTIONAL_TESTS_PATH, self.controller_class_path) unless options[:skip_tests]
      m.directory File.join(UNIT_TESTS_PATH, self.controller_class_path) unless options[:skip_tests]
      
      # Controllers.
      controller_template = options[:resourceful] ? 'inherited_resources' : 'standard'
      m.template "controller_#{controller_template}.rb",
        File.join(CONTROLLERS_PATH, self.controller_class_path, "#{self.controller_file_name}_controller.rb")
        
      # Controller Tests.
      unless options[:skip_tests]
        m.template "controller_test_standard.rb",
          File.join(FUNCTIONAL_TESTS_PATH, self.controller_class_path, "#{self.controller_file_name}_controller_test.rb")
      end
      
      # Helpers.
      unless options[:skip_helpers]
        m.template "helper_standard.rb",
          File.join(HELPERS_PATH, self.controller_class_path, "#{self.controller_file_name}_helper.rb")
        # Helper Tests
        unless options[:skip_tests]
          m.template "helper_test_standard.rb",
            File.join(UNIT_TESTS_PATH, self.controller_class_path, "#{self.controller_file_name}_helper_test.rb")
        end
      end
        
      # Views.
      unless options[:skip_views]
        # View template for each action.
        ACTIONS.each do |action|
          m.template "view_#{action}.html.haml",
            File.join(VIEWS_PATH, self.controller_file_name, "#{action}.html.haml")
        end
        # View template for each partial.
        PARTIALS.each do |partial|
          m.template "view__#{partial}.html.haml",
            File.join(VIEWS_PATH, self.controller_file_name, "_#{partial}.html.haml")
        end
      end
      
      # Routes.
      m.route_resources self.controller_file_name
      
      # Models - use Rails default generator.
      m.dependency 'model', [self.name] + @args, :collision => :skip
    end
  end
  
  protected
    
    def assign_names!(name)
      super
      @collection_name = self.options[:resourceful] ? RESOURCEFUL_COLLECTION_NAME : @plural_name
      @singular_name = self.options[:resourceful] ? RESOURCEFUL_SINGULAR_NAME : @singular_name
      @plural_name = self.options[:resourceful] ? RESOURCEFUL_SINGULAR_NAME.pluralize : @plural_name
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      
      opt.on('--skip-resourceful',
        "Skip 'inherited_resources' style controllers and views. Requires gem 'josevalim-inherited_resources'.") do |v|
        self.options[:resourceful] = !v
      end
      
      opt.on('--skip-formtastic',
        "Skip 'formtastic' style forms. Requires gem 'justinfrench-formtastic'.") do |v|
        self.options[:formtastic] = !v
      end
      
      opt.on('--skip-views', "Skip generation of views.") do |v|
        self.options[:skip_views] = v
      end
      
      opt.on('--skip-helper', "Skip generation of helpers.") do |v|
        self.options[:skip_helpers] = v
      end
      
      opt.on('--skip-tests', "Skip generation of tests.") do |v|
        self.options[:skip_tests] = v
      end
      
      opt.on('-r', '--respond-to', "Skip generation of tests.") do |v|
        puts v
        self.options[:respond_to] = v
      end
    end
    
    def model_name
      class_name.demodulize
    end
    
    def banner
      "Usage: #{$0} dry_scaffold ModelName [field:type field:type ...]" +
        " [--skip-resourceful] [--skip-formtastic]" +
        " [--skip-views] [--skip-helpers] [--skip-tests]"
    end
    
end