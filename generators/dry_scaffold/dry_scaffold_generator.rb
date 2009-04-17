class DryScaffoldGenerator < Rails::Generator::NamedBase
  
  default_options :no_resourceful => false, :no_formtastic => false,
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
  
  attr_reader   :collection_name
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name
                
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name
  
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
      m.class_collisions "#{self.controller_class_name}Controller", "#{self.controller_class_name}ControllerTest"
      m.class_collisions "#{self.controller_class_name}Helper", "#{self.controller_class_name}HelperTest"
      m.class_collisions self.class_path, "#{self.class_name}"
      
      # Directories.
      m.directory File.join(CONTROLLERS_PATH, self.controller_class_path)
      m.directory File.join(HELPERS_PATH, self.controller_class_path) unless options[:skip_helpers]
      m.directory File.join(VIEWS_PATH, self.class_path) unless options[:skip_views]
      m.directory File.join(FUNCTIONAL_TESTS_PATH, self.controller_class_path) unless options[:skip_tests]
      m.directory File.join(UNIT_TESTS_PATH, self.controller_class_path) unless options[:skip_tests]
      
      # Controllers.
      controller_template = options[:no_resourceful] ? 'standard' : 'inherited_resources'
      m.template "controller_#{controller_template}.rb",
        File.join(CONTROLLERS_PATH, self.controller_class_path, "#{self.controller_file_name}_controller.rb")
        
      # Controller Tests.
      unless options[:skip_tests]
        m.template 'controller_test_standard.rb',
          File.join(FUNCTIONAL_TESTS_PATH, self.controller_class_path, "#{self.controller_file_name}_controller_test.rb")
      end
      
      # Helpers.
      unless options[:skip_helpers]
        m.template 'helper_standard.rb',
          File.join(HELPERS_PATH, self.controller_class_path, "#{self.controller_file_name}_helper.rb")
        # Helper Tests
        unless options[:skip_tests]
          m.template 'helper_test_standard.rb',
            File.join(UNIT_TESTS_PATH, self.controller_class_path, "#{self.controller_file_name}_helper_test.rb")
        end
      end
        
      # Views.
      unless options[:skip_views]
        # View template for each action.
        ACTIONS.each do |action|
          m.template "view_#{action}.html.haml",
            File.join(VIEWS_PATH, self.file_name, "#{action}.html.haml"),
            :assigns => {:options => options}
        end
        # View template for each partial.
        PARTIALS.each do |partial|
          m.template "view__#{partial}.html.haml",
            File.join(VIEWS_PATH, self.file_name, "#{partial}.html.haml"),
            :assigns => {:options => options}
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
      @collection_name = options[:skip_resourceful] ? @plural_name : RESOURCEFUL_COLLECTION_NAME
      @singular_name = options[:skip_resourceful] ? @singular_name : RESOURCEFUL_SINGULAR_NAME
      @plural_name = options[:skip_resourceful] ? @plural_name : RESOURCEFUL_SINGULAR_NAME.pluralize
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      
      opt.on('-r', '--no-resourceful',
        "Skip 'inherited_resources' style controllers and views. Requires gem 'josevalim-inherited_resources'.") do |v|
        options[:no_resourceful] = v
      end
      
      opt.on('-f', '--no-formtastic',
        "Skip 'formtastic' style forms. Requires gem 'justinfrench-formtastic'") do |v|
        options[:no_formtastic] = v
      end
      
      opt.on('-v', '--skip-views', "Skip generation of views.") do |v|
        options[:skip_views] = v
      end
      
      opt.on('-h', '--skip-helper', "Skip generation of helpers.") do |v|
        options[:skip_helpers] = v
      end
      
      opt.on('-t', '--skip-tests', "Skip generation of tests.") do |v|
        options[:skip_tests] = v
      end
      
      opt.on('-rt', '--respond-to', "Skip generation of tests.") do |v|
        options[:respond_to] = v
      end
    end
    
    def model_name
      class_name.demodulize
    end
    
    def banner
      "Usage: #{$0} dry_scaffold ModelName [-r/--no-resourceful] [-f/--no-formtastic]" +
        " [-v/--skip-views] [-h/--skip-helpers] [-t/--skip-tests]"
    end
    
end
