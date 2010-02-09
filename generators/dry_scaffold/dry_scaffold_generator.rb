require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'dry_generator'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'dry_model', 'dry_model_generator'))

class DryScaffoldGenerator < DryGenerator
  
  # Banner: Generator arguments and options.
  BANNER_ARGS = [
      "[_actions:new,create,...]",
      "[_formats:html,json,...]",
      DryModelGenerator::BANNER_ARGS
    ].freeze
  BANNER_OPTIONS = [
      "[--skip-pagination]",
      "[--skip-resourceful]",
      "[--skip-formtastic]",
      "[--skip-views]",
      "[--skip-builders]",
      "[--skip-helpers]",
      "[--layout]",
      DryModelGenerator::BANNER_OPTIONS
    ].freeze
    
  # Paths.
  CONTROLLERS_PATH =        File.join('app', 'controllers').freeze
  HELPERS_PATH =            File.join('app', 'helpers').freeze
  VIEWS_PATH =              File.join('app', 'views').freeze
  LAYOUTS_PATH =            File.join(VIEWS_PATH, 'layouts').freeze
  
  ROUTES_FILE_PATH =        File.join(RAILS_ROOT, 'config', 'routes.rb').freeze
  
  # Formats.
  DEFAULT_RESPOND_TO_FORMATS =          [:html, :xml, :json].freeze
  ENHANCED_RESPOND_TO_FORMATS =         [:yml, :yaml, :txt, :text, :atom, :rss].freeze
  RESPOND_TO_FEED_FORMATS =             [:atom, :rss].freeze
  
  # Actions.
  DEFAULT_MEMBER_ACTIONS =              [:show, :new, :edit, :create, :update, :destroy].freeze
  DEFAULT_MEMBER_AUTOLOAD_ACTIONS =     (DEFAULT_MEMBER_ACTIONS - [:new, :create])
  DEFAULT_COLLECTION_ACTIONS =          [:index].freeze
  DEFAULT_COLLECTION_AUTOLOAD_ACTIONS = DEFAULT_COLLECTION_ACTIONS
  DEFAULT_CONTROLLER_ACTIONS =          (DEFAULT_COLLECTION_ACTIONS + DEFAULT_MEMBER_ACTIONS)
  
  DEFAULT_VIEW_TEMPLATE_FORMAT =        :haml
  
  RESOURCEFUL_COLLECTION_NAME =         'collection'.freeze
  RESOURCEFUL_SINGULAR_NAME =           'resource'.freeze
  
  # :{action} => [:{partial}, ...]
  ACTION_VIEW_TEMPLATES = {
      :index  => [:item],
      :show   => [],
      :new    => [:form],
      :edit   => [:form]
    }.freeze
    
  ACTION_FORMAT_BUILDERS = {
      :index => [:atom, :rss]
    }
    
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
                :formats,
                :config
                
  alias_method  :controller_file_name, :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    @options = DEFAULT_OPTIONS.merge(options)
    super(runtime_args, runtime_options.merge(@options))
    
    @controller_name = @name.pluralize
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name = base_name.singularize
    
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    
    @view_template_format = options[:view_template_format] || DEFAULT_VIEW_TEMPLATE_FORMAT
    
    @attributes ||= []
    @args_for_model ||= []
    
    # Non-attribute args, i.e. "_actions:new,create".
    @args.each do |arg|
      arg_entities = arg.split(':')
      if arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}/
        if arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}action/
          # Replace quantifiers with default actions.
          arg_entities[1].gsub!(/\*/, DEFAULT_CONTROLLER_ACTIONS.join(','))
          arg_entities[1].gsub!(/new\+/, [:new, :create].join(','))
          arg_entities[1].gsub!(/edit\+/, [:edit, :update].join(','))
          
          arg_actions = arg_entities[1].split(',').compact.uniq
          @actions = arg_actions.collect { |action| action.downcase.to_sym }
        elsif arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}(format|respond_to)/
          # Replace quantifiers with default respond_to-formats.
          arg_entities[1].gsub!(/\*/, DEFAULT_RESPOND_TO_FORMATS.join(','))
          
          arg_formats = arg_entities[1].split(',').compact.uniq
          @formats = arg_formats.collect { |format| format.downcase.to_sym }
        elsif arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}index/
          @args_for_model << arg
        end
      else
        @attributes << Rails::Generator::GeneratedAttribute.new(*arg_entities)
        @args_for_model << arg
      end
    end
    
    @actions ||= DEFAULT_ARGS[:actions] || DEFAULT_CONTROLLER_ACTIONS
    @formats ||= DEFAULT_ARGS[:formats] || DEFAULT_RESPOND_TO_FORMATS
  end
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions "#{controller_class_name}Controller", "#{controller_class_name}ControllerTest"
      m.class_collisions "#{controller_class_name}Helper", "#{controller_class_name}HelperTest"
      
      # Controllers.
      controller_template = options[:resourceful] ? 'inherited_resources' : 'action'
      m.directory File.join(CONTROLLERS_PATH, controller_class_path)
      m.template File.join('controllers', "#{controller_template}_controller.rb"),
        File.join(CONTROLLERS_PATH, controller_class_path, "#{controller_file_name}_controller.rb")
        
      # Controller Tests.
      unless options[:skip_tests] || options[:skip_controller_tests]
        controller_tests_path = File.join(TEST_PATHS[test_framework], FUNCTIONAL_TESTS_PATH[test_framework])
        m.directory File.join(controller_tests_path, controller_class_path)
        m.template File.join('controllers', 'tests', "#{test_framework}", 'functional_test.rb'),
          File.join(controller_tests_path, controller_class_path, "#{controller_file_name}_controller_#{TEST_POST_FIX[test_framework]}.rb")
      end
      
      # Helpers.
      unless options[:skip_helpers]
        m.directory File.join(HELPERS_PATH, controller_class_path)
        m.template File.join('helpers', 'helper.rb'),
          File.join(HELPERS_PATH, controller_class_path, "#{controller_file_name}_helper.rb")
          
        # Helper Tests
        unless options[:skip_tests]
          helper_tests_path = File.join(TEST_PATHS[test_framework], 'helpers')
          m.directory File.join(helper_tests_path, controller_class_path)
          m.template File.join('helpers', 'tests', "#{test_framework}", 'unit_test.rb'),
            File.join(helper_tests_path, controller_class_path, "#{controller_file_name}_helper_#{TEST_POST_FIX[test_framework]}.rb")
        end
      end
      
      # Views.
      unless options[:skip_views]
        m.directory File.join(VIEWS_PATH, controller_class_path, controller_file_name)
        # View template for each action.
        (actions & ACTION_VIEW_TEMPLATES.keys).each do |action|
          m.template File.join('views', "#{view_template_format}", "#{action}.html.#{view_template_format}"),
            File.join(VIEWS_PATH, controller_file_name, "#{action}.html.#{view_template_format}")
            
          # View template for each partial - if not already copied.
          (ACTION_VIEW_TEMPLATES[action] || []).each do |partial|
            m.template File.join('views', "#{view_template_format}", "_#{partial}.html.#{view_template_format}"),
              File.join(VIEWS_PATH, controller_file_name, "_#{partial}.html.#{view_template_format}")
          end
        end
      end
      
      # Builders.
      unless options[:skip_builders]
        m.directory File.join(VIEWS_PATH, controller_class_path, controller_file_name)
        (actions & ACTION_FORMAT_BUILDERS.keys).each do |action|
          (formats & ACTION_FORMAT_BUILDERS[action] || []).each do |format|
            m.template File.join('views', 'builder', "#{action}.#{format}.builder"),
              File.join(VIEWS_PATH, controller_file_name, "#{action}.#{format}.builder")
          end
        end
      end
      
      # Layout.
      if options[:layout]
        m.directory File.join(LAYOUTS_PATH)
        m.template File.join('views', "#{view_template_format}", "layout.html.#{view_template_format}"),
          File.join(LAYOUTS_PATH, "#{controller_file_name}.html.#{view_template_format}")
      end
      
      # Routes.
      unless resource_route_exists?
        # TODO: Override Rails default method to not generate route if it's already defined.
        m.route_resources controller_file_name
      end
      
      # Models - use Rails default generator.
      m.dependency 'dry_model', [name] + @args_for_model, options.merge(:collision => :skip)
    end
  end
  
  ### Fixture/Factory Helpers.
  
  def build_object
    case options[:factory_framework]
      when :factory_girl then
        "Factory(:#{singular_name})"
      when :machinist then
        "#{class_name}.make"
      when :object_daddy then
        "#{class_name}.generate"
      else #:fixtures
        "#{table_name}(:basic)"
    end
  end
  
  ### Link Helpers.
  
  def collection_instance
    options[:resourceful] ? "#{collection_name}" : "@#{collection_name}"
  end
  
  def resource_instance
    options[:resourceful] ? "#{singular_name}" : "@#{singular_name}"
  end
  
  def index_path
    "#{collection_name}_path"
  end
  
  def new_path
    "new_#{singular_name}_path"
  end
  
  def show_path(object_name = resource_instance)
    "#{singular_name}_path(#{object_name})"
  end
  
  def edit_path(object_name = resource_instance)
    "edit_#{show_path(object_name)}"
  end
  
  def destroy_path(object_name = resource_instance)
    "#{object_name}"
  end
  
  def index_url
    "#{collection_name}_url"
  end
  
  def new_url
    "new_#{singular_name}_url"
  end
  
  def show_url(object_name = resource_instance)
    "#{singular_name}_url(#{object_name})"
  end
  
  def edit_url(object_name = resource_instance)
    "edit_#{show_url(object_name)}"
  end
  
  def destroy_url(object_name = resource_instance)
    "#{object_name}"
  end
  
  ### Feed Helpers.
  
  def feed_link(format)
    case format
      when :atom then
        ":href => #{plural_name}_url(:#{format}), :rel => 'self'"
      when :rss then
        "#{plural_name}_url(#{singular_name}, :#{format})"
    end
  end
  
  def feed_entry_link(format)
    case format
      when :atom then
        ":href => #{singular_name}_url(#{singular_name}, :#{format})"
      when :rss then
        "#{singular_name}_url(#{singular_name}, :#{format})"
    end
  end
  
  def feed_date(format)
    case format
      when :atom then
        "(#{collection_instance}.first.created_at rescue Time.now.utc).strftime('%Y-%m-%dT%H:%M:%SZ')"
      when :rss then
        "(#{collection_instance}.first.created_at rescue Time.now.utc).to_s(:rfc822)"
    end
  end
  
  def feed_entry_date(format)
    case format
      when :atom then
        "#{singular_name}.try(:updated_at).strftime('%Y-%m-%dT%H:%M:%SZ')"
      when :rss then
        "#{singular_name}.try(:updated_at).to_s(:rfc822)"
    end
  end
  
  protected
    
    def resource_route_exists?
      route_exp = "map.resources :#{controller_file_name}"
      File.read(ROUTES_FILE_PATH) =~ /(#{route_exp.strip}|#{route_exp.strip.tr('\'', '\"')})/
    end
    
    def assign_names!(name)
      super(name)
      @model_singular_name = @singular_name
      @model_plural_name = @plural_name
      @collection_name = options[:resourceful] ? RESOURCEFUL_COLLECTION_NAME : @model_plural_name
      @singular_name = options[:resourceful] ? RESOURCEFUL_SINGULAR_NAME : @model_singular_name
      @plural_name = options[:resourceful] ? RESOURCEFUL_SINGULAR_NAME.pluralize : @model_plural_name
    end
    
    def add_options!(opt)
      super(opt)
      
      ### CONTROLLER + VIEW + HELPER
      
      opt.separator ' '
      opt.separator 'Scaffold Options:'
      
      opt.on('--skip-resourceful',
        "Controller: Skip 'inherited_resources' style controllers and views. Requires gem 'josevalim-inherited_resources'.") do |v|
        options[:resourceful] = !v
      end
      
      opt.on('--skip-pagination',
        "Controller/View: Skip 'will_paginate' for collections in controllers and views. Requires gem 'mislav-will_paginate'.") do |v|
        options[:pagination] = !v
      end
      
      opt.on('--skip-formtastic',
        "View: Skip 'formtastic' style forms. Requires gem 'justinfrench-formtastic'.") do |v|
        options[:formtastic] = !v
      end
      
      opt.on("--skip-controller-tests", "Controller: Skip generation of tests for controller.") do |v|
        options[:skip_controller_tests] = v
      end

      opt.on('--skip-views', "View: Skip generation of views.") do |v|
        options[:skip_views] = v
      end
      
      opt.on('--skip-builders', "View: Skip generation of builders.") do |v|
        options[:skip_builders] = v
      end
      
      opt.on('--layout', "View: Generate layout.") do |v|
        options[:layout] = v
      end
      
      opt.on('--skip-helper', "Helper: Skip generation of helpers.") do |v|
        options[:skip_helpers] = v
      end
      
      ### MODEL
      
      opt.separator ' '
      opt.separator 'Model Options:'
      
      opt.on("--skip-timestamps", "Model: Don't add timestamps to the migration file.") do |v|
        options[:skip_timestamps] = v
      end
      
      opt.on("--skip-migration", "Model: Skip generation of migration file.") do |v|
        options[:skip_migration] = v
      end
      
      opt.on("--skip-tests", "Model: Skip generation of tests.") do |v|
        options[:skip_tests] = v
      end
      
      opt.on("--skip-controller tests", "Controller: Skip generation of tests for controller.") do |v|
        options[:skip_controller_tests] = v
      end
      
      opt.separator ' '
    end
    
    def banner_args
      [BANNER_ARGS, super].flatten.join(' ')
    end
    
    def banner_options
      [BANNER_OPTIONS, super].flatten.join(' ')
    end
    
    def banner
      [super, banner_args, banner_options].join(' ')
    end
    
end
