class DryScaffoldGenerator < Rails::Generator::NamedBase
  
  default_options :skip_resourceful => false, 
                  :skip_formtastic => false,
                  :skip_tests => false,
                  :skip_helpers => false,
                  :skip_views => false,
                  :include_layout => false
                  
  CONTROLLERS_PATH = File.join('app', 'controllers').freeze
  HELPERS_PATH = File.join('app', 'helpers').freeze
  VIEWS_PATH = File.join('app', 'views').freeze
  LAYOUTS_PATH = File.join(VIEWS_PATH, 'layouts').freeze
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
      m.class_collisions "#{controller_class_name}Controller", "#{controller_class_name}ControllerTest"
      m.class_collisions "#{controller_class_name}Helper", "#{controller_class_name}HelperTest"
      m.class_collisions "#{class_path}", "#{class_name}"
      
      # Directories.
      m.directory File.join(CONTROLLERS_PATH, controller_class_path)
      m.directory File.join(HELPERS_PATH, controller_class_path) unless options[:skip_helpers]
      m.directory File.join(VIEWS_PATH, controller_class_path, controller_file_name.pluralize) unless options[:skip_views]
      m.directory File.join(FUNCTIONAL_TESTS_PATH, controller_class_path) unless options[:skip_tests]
      m.directory File.join(UNIT_TESTS_PATH, controller_class_path) unless options[:skip_tests]
      
      # Controllers.
      logger.debug "controller-template: %s" % controller_template = options[:resourceful] ? 'inherited_resources' : 'standard'
      m.template "controller_#{controller_template}.rb",
        File.join(CONTROLLERS_PATH, controller_class_path, "#{controller_file_name}_controller.rb")
        
      # Controller Tests.
      unless options[:skip_tests]
        m.template "controller_test_standard.rb",
          File.join(FUNCTIONAL_TESTS_PATH, controller_class_path, "#{controller_file_name}_controller_test.rb")
      end
      
      # Helpers.
      unless options[:skip_helpers]
        m.template "helper_standard.rb",
          File.join(HELPERS_PATH, controller_class_path, "#{controller_file_name}_helper.rb")
        # Helper Tests
        unless options[:skip_tests]
          m.template "helper_test_standard.rb",
            File.join(UNIT_TESTS_PATH, controller_class_path, "#{controller_file_name}_helper_test.rb")
        end
      end
        
      # Views.
      unless options[:skip_views]
        # View template for each action.
        ACTIONS.each do |action|
          m.template "view_#{action}.html.haml",
            File.join(VIEWS_PATH, controller_file_name, "#{action}.html.haml")
        end
        # View template for each partial.
        PARTIALS.each do |partial|
          m.template "view__#{partial}.html.haml",
            File.join(VIEWS_PATH, controller_file_name, "_#{partial}.html.haml")
        end
      end
      
      if options[:include_layout]
        m.template "view_layout.html.haml",
          File.join(LAYOUTS_PATH, "#{controller_file_name}.html.haml")
      end
      
      # Routes.
      m.route_resources controller_file_name
      
      # Models - use Rails default generator.
      m.dependency 'model', [name] + @args, :collision => :skip
    end
  end
  
  protected
    
    def assign_names!(name)
      super
      @collection_name = options[:resourceful] ? RESOURCEFUL_COLLECTION_NAME : @plural_name
      @singular_name = options[:resourceful] ? RESOURCEFUL_SINGULAR_NAME : @singular_name
      @plural_name = options[:resourceful] ? RESOURCEFUL_SINGULAR_NAME.pluralize : @plural_name
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      
      opt.on('--skip-resourceful',
        "Skip 'inherited_resources' style controllers and views. Requires gem 'josevalim-inherited_resources'.") do |v|
        options[:resourceful] = !v
      end
      
      opt.on('--skip-formtastic',
        "Skip 'formtastic' style forms. Requires gem 'justinfrench-formtastic'.") do |v|
        options[:formtastic] = !v
      end
      
      opt.on('--skip-views', "Skip generation of views.") do |v|
        options[:skip_views] = v
      end
      
      opt.on('--skip-helper', "Skip generation of helpers.") do |v|
        options[:skip_helpers] = v
      end
      
      opt.on('--skip-tests', "Skip generation of tests.") do |v|
        options[:skip_tests] = v
      end
      
      opt.on('--include-layout', "Generate layout.") do |v|
        options[:include_layout] = v
      end
      
      # TODO: How to specify arguments?
      opt.on('-r', '--respond-to', "Skip generation of tests.") do |v|
        puts v
        options[:respond_to] = v
      end
    end
    
    def model_name
      class_name.demodulize
    end
    
    def banner
      "Usage: #{$0} dry_scaffold ModelName [field:type field:type ...]" +
        " [--skip-resourceful] [--skip-formtastic]" +
        " [--skip-views] [--skip-helpers] [--skip-tests] [--include-layout]"
    end
    
end