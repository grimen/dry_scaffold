require 'rubygems'
begin
  require 'formtastic'
  FORMTASTIC = true
rescue
  FORMTASTIC = false
end
begin
  require 'inherited_resources'
  INHERITED_RESOURCES = true
rescue
  INHERITED_RESOURCES = false
end
begin
  require 'will_paginate'
  WILL_PAGINATE = true
rescue
  WILL_PAGINATE = false
end

class DryScaffoldGenerator < Rails::Generator::NamedBase
  
  DEFAULT_RESPOND_TO_FORMATS =          [:html, :xml, :json].freeze
  DEFAULT_MEMBER_ACTIONS =              [:show, :new, :edit, :create, :update, :destroy].freeze
  DEFAULT_MEMBER_AUTOLOAD_ACTIONS =     (DEFAULT_MEMBER_ACTIONS - [:new, :create])
  DEFAULT_COLLECTION_ACTIONS =          [:index].freeze
  DEFAULT_COLLECTION_AUTOLOAD_ACTIONS = DEFAULT_COLLECTION_ACTIONS
  DEFAULT_CONTROLLER_ACTIONS =          (DEFAULT_COLLECTION_ACTIONS + DEFAULT_MEMBER_ACTIONS)
  
  DEFAULT_VIEW_TEMPLATE_FORMAT =        :haml
  
  CONTROLLERS_PATH =      File.join('app', 'controllers').freeze
  HELPERS_PATH =          File.join('app', 'helpers').freeze
  VIEWS_PATH =            File.join('app', 'views').freeze
  LAYOUTS_PATH =          File.join(VIEWS_PATH, 'layouts').freeze
  MODELS_PATH =           File.join('app', 'models').freeze
  FUNCTIONAL_TESTS_PATH = File.join('test', 'functional').freeze
  UNIT_TESTS_PATH =       File.join('test', 'unit', 'helpers').freeze
  
  RESOURCEFUL_COLLECTION_NAME = 'collection'.freeze
  RESOURCEFUL_SINGULAR_NAME =   'resource'.freeze
  
  NON_ATTR_ARG_KEY_PREFIX =     '_'.freeze
  
  # :{action} => [:{partial}, ...]
  VIEW_TEMPLATES = {
    :index  => [:item],
    :show   => [],
    :new    => [:form],
    :edit   => [:form]
  }.freeze
  
  default_options :resourceful => INHERITED_RESOURCES,
                  :formtastic => FORMTASTIC,
                  :pagination => WILL_PAGINATE,
                  :skip_tests => false,
                  :skip_helpers => false,
                  :skip_views => false,
                  :include_layout => false
                  
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :collection_name,
                :model_singular_name,
                :model_plural_name,
                :view_template_format,
                :actions,
                :formats
                
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
    
    @view_template_format = DEFAULT_VIEW_TEMPLATE_FORMAT
    
    @attributes ||= []
    @args_for_model ||= []
    
    # Non-attribute args, i.e. "_actions:new,create".
    @args.each do |arg|
      arg_entities = arg.split(':')
      if arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}/
        if arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}action/
          # Replace a '*' with default actions
          arg_entities[1].gsub!(/\*/, DEFAULT_CONTROLLER_ACTIONS.join(','))
          arg_actions = arg_entities[1].split(',').compact.uniq
          @actions = arg_actions.collect { |action| action.downcase.to_sym }
        elsif arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}(format|respond_to)/
          # Replace a '*' with default respond_to-formats
          arg_entities[1].gsub!(/\*/, DEFAULT_RESPOND_TO_FORMATS.join(','))
          arg_formats = arg_entities[1].split(',').compact.uniq
          @formats = arg_formats.collect { |format| format.downcases.to_sym }
        end
      else
        @attributes << Rails::Generator::GeneratedAttribute.new(*arg_entities)
        @args_for_model << arg
      end
    end
    
    @actions ||= DEFAULT_CONTROLLER_ACTIONS
    @formats ||= DEFAULT_RESPOND_TO_FORMATS
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
      m.directory File.join(VIEWS_PATH, controller_class_path, controller_file_name) unless options[:skip_views]
      m.directory File.join(FUNCTIONAL_TESTS_PATH, controller_class_path) unless options[:skip_tests]
      m.directory File.join(UNIT_TESTS_PATH, controller_class_path) unless options[:skip_tests]
      
      # Controllers.
      controller_template = options[:resourceful] ? 'inherited_resources' : 'standard'
      m.template "controller_#{controller_template}.rb",
        File.join(CONTROLLERS_PATH, controller_class_path, "#{controller_file_name}_controller.rb")
        
      # Controller Tests.
      unless options[:skip_tests]
        m.template 'functional_test_standard.rb',
          File.join(FUNCTIONAL_TESTS_PATH, controller_class_path, "#{controller_file_name}_controller_test.rb")
      end
      
      # Helpers.
      unless options[:skip_helpers]
        m.template 'helper_standard.rb',
          File.join(HELPERS_PATH, controller_class_path, "#{controller_file_name}_helper.rb")
        # Helper Tests
        unless options[:skip_tests]
          m.template 'helper_test_standard.rb',
            File.join(UNIT_TESTS_PATH, controller_class_path, "#{controller_file_name}_helper_test.rb")
        end
      end
      
      # Views.
      unless options[:skip_views]
        # View template for each action.
        (actions & VIEW_TEMPLATES.keys).each do |action|
          m.template "view_#{action}.html.#{view_template_format}", File.join(VIEWS_PATH, controller_file_name, "#{action}.html.#{view_template_format}")
          # View template for each partial - if not already copied.
          (VIEW_TEMPLATES[action] || []).each do |partial|
            m.template "view__#{partial}.html.#{view_template_format}",
              File.join(VIEWS_PATH, controller_file_name, "_#{partial}.html.#{view_template_format}")
          end
        end
      end
      
      # Layout.
      if options[:include_layout]
        m.template "view_layout.html.#{view_template_format}",
          File.join(LAYOUTS_PATH, "#{controller_file_name}.html.#{view_template_format}")
      end
      
      # Routes.
      m.route_resources controller_file_name
      
      # Models - use Rails default generator.
      m.dependency 'dry_model',
        [name] + @args_for_model +
        options.slice(:skip_tests,
            :fixtures,
            :factory_girl,
            :machinist,
            :object_daddy,
            :skip_timestamps,
            :skip_migration
          ),
        :collision => :skip
    end
  end
  
  protected
    
    def symbol_array_to_expression(array)
      ":#{array.compact.join(', :')}" if array.present?
    end
    
    def assign_names!(name)
      super
      @model_singular_name = @singular_name
      @model_plural_name = @plural_name
      @collection_name = options[:resourceful] ? RESOURCEFUL_COLLECTION_NAME : @model_plural_name
      @singular_name = options[:resourceful] ? RESOURCEFUL_SINGULAR_NAME : @model_singular_name
      @plural_name = options[:resourceful] ? RESOURCEFUL_SINGULAR_NAME.pluralize : @model_plural_name
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      
      opt.on('--skip-pagination',
        "Skip 'will_paginate' for collections in controllers and views, wich requires gem 'mislav-will_paginate'.") do |v|
        options[:pagination] = !v
      end
      
      opt.on('--skip-resourceful',
        "Skip 'inherited_resources' style controllers and views, wich requires gem 'josevalim-inherited_resources'.") do |v|
        options[:resourceful] = !v
      end
      
      opt.on('--skip-formtastic',
        "Skip 'formtastic' style forms, wich requires gem 'justinfrench-formtastic'.") do |v|
        options[:formtastic] = !v
      end
      
      opt.on('--layout', "Generate layout.") do |v|
        options[:include_layout] = v
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
      
      opt.on('--fixtures', "Model: Generate fixtures.") do |v|
        options[:fixtures] = v
      end
      
      opt.on('--fgirl', "Model: Generate \"factory_girl\" factories.") do |v|
        options[:machinist] = v
      end
      
      opt.on('--machinist', "Model: Generate \"machinist\" blueprints (factories).") do |v|
        options[:factory_girl] = v
      end
      
      opt.on('--odaddy', "Model: Generate \"object_daddy\" generator/factory methods.") do |v|
        options[:object_daddy] = v
      end
      
      opt.on('--skip-timestamps', "Model: Don't add timestamps to the migration file.") do |v|
        options[:skip_timestamps] = v
      end
      
      opt.on('--skip-migration', "Model: Skip generation of migration file.") do |v|
        options[:skip_migration] = v
      end
    end
    
    def banner
      ["Usage: #{$0} #{spec.name} ModelName",
        "[field:type field:type ...]",
        "[_actions:new,create,...]",
        "[_formats:html,json,...]",
        "[_indexes:field,field+field,field,...]",
        "[--skip-pagination]",
        "[--skip-resourceful]",
        "[--skip-formtastic]",
        "[--skip-views]", 
        "[--skip-helpers]",
        "[--skip-tests]",
        "[--layout]",
        "[--fixtures]",
        "[--factory_girl]",
        "[--machinist]",
        "[--object_daddy]",
        "[--skip-timestamps]",
        "[--skip-migration]",
      ].join(' ')
    end
    
end