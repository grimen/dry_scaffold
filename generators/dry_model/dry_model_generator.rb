require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'dry_generator'))

class DryModelGenerator < DryGenerator
  
  # Banner: Generator arguments and options.
  BANNER_ARGS = [
      "[_indexes:field,field+field,field,...]"
    ].freeze
  BANNER_OPTIONS = [
      "[--skip-timestamps]",
      "[--skip-migration]"
    ].freeze
    
  # Paths.
  MODELS_PATH =           File.join('app', 'models').freeze
  MIGRATIONS_PATH =       File.join('db', 'migrate').freeze
  
  attr_reader :indexes,
              :references
              
  def initialize(runtime_args, runtime_options = {})
    super(runtime_args, runtime_options)
    
    @attributes ||= []
    args_for_model = []
    
    @args.each do |arg|
      arg_entities = arg.split(':')
      if arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}/
        if arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}index/
          arg_indexes = arg_entities[1].split(',').compact.uniq
          @indexes = arg_indexes.collect do |index|
            if index =~ /\+/
              index.split('+').collect { |i| i.downcase.to_sym  }
            else
              index.downcase.to_sym
            end
          end
        end
      else
        @attributes << Rails::Generator::GeneratedAttribute.new(*arg_entities)
        args_for_model << arg
      end
    end
    
    @args = args_for_model
    @references = attributes.select(&:reference?)
    @options = DEFAULT_OPTIONS.merge(options)
  end
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_name, "#{class_name}Test"
      
      # Model.
      m.directory File.join(MODELS_PATH, class_path)
      m.template File.join('models', 'active_record_model.rb'),
        File.join(MODELS_PATH, class_path, "#{file_name}.rb")
        
      # Model Tests.
      unless options[:skip_tests]
        model_tests_path = File.join(TEST_PATHS[test_framework], UNIT_TESTS_PATH[test_framework])
        m.directory File.join(model_tests_path, class_path)
        m.template File.join('models', 'tests', "#{test_framework}", 'unit_test.rb'),
          File.join(model_tests_path, class_path, "#{file_name}_#{TEST_POST_FIX[test_framework]}.rb")
          
        # Fixtures/Factories.
        if options[:fixtures]
          fixtures_path = File.join(TEST_PATHS[test_framework], 'fixtures')
          m.directory File.join(fixtures_path, class_path)
          m.template File.join('models', 'fixture_data', 'active_record_fixtures.yml'),
            File.join(fixtures_path, class_path, "#{table_name}.yml")
        end
        if options[:factory_girl]
          factory_girl_path = File.join(TEST_PATHS[test_framework], 'factories')
          m.directory File.join(factory_girl_path, class_path)
          m.template File.join('models', 'fixture_data', 'factory_girl_factories.rb'),
            File.join(factory_girl_path, class_path, "#{plural_name}.rb")
        end
        if options[:machinist]
          machinist_path = File.join(TEST_PATHS[test_framework], 'blueprints')
          m.directory File.join(machinist_path, class_path)
          m.template File.join('models', 'fixture_data', 'machinist_blueprints.rb'),
            File.join(machinist_path, class_path, "#{plural_name}.rb")
        end
        # NOTE: :object_daddy handled in model
      end
      
      # Migration.
      unless options[:skip_migration]
        m.migration_template File.join('models', 'active_record_migration.rb'), MIGRATIONS_PATH,
          :assigns => {:migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"},
          :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end
  end
  
  protected
    
    def add_options!(opt)
      super(opt)
      
      opt.separator ' '
      opt.separator 'Model Options:'
      
      opt.on("--skip-timestamps", "Don't add timestamps to the migration file.") do |v|
        options[:skip_timestamps] = v
      end
      
      opt.on("--skip-migration", "Skip generation of migration file.") do |v|
        options[:skip_migration] = v
      end
      
      opt.on("--skip-tests", "Skip generation of tests.") do |v|
        options[:skip_tests] = v
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
