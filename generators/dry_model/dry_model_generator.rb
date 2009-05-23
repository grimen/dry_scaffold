require 'rubygems'
%w(factory_girl machinist object_daddy).each do |lib|
  begin
    require lib
  rescue MissingSourceFile
    eval("#{lib.upcase} = #{false}")
  else
    eval("#{lib.upcase} = #{true}")
  end
end

class DryModelGenerator < Rails::Generator::NamedBase
  
  # Load defaults from config file - default or custom.
  begin
    default_config_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'scaffold.yml'))
    custom_config_file = File.expand_path(File.join(Rails.root, 'config', 'scaffold.yml'))
    config_file = File.join(File.exist?(custom_config_file) ? custom_config_file : default_config_file)
    config = YAML::load(File.open(config_file))
    CONFIG_OPTIONS = config['dry_model']['options'] rescue nil
  end
  
  DEFAULT_OPTIONS = {
      :fixtures => CONFIG_OPTIONS['fixtures'] || false,
      :factory_girl => CONFIG_OPTIONS['factory_girl'] || false,
      :machinist => CONFIG_OPTIONS['machinist'] || false,
      :object_daddy => CONFIG_OPTIONS['object_daddy'] || false,
      :skip_timestamps => !CONFIG_OPTIONS['timestamps'] || false,
      :skip_migration => !CONFIG_OPTIONS['migration'] || false,
      :skip_tests => !CONFIG_OPTIONS['tests'] || false
    }
    
  DEFAULT_TEST_FRAMEWORK =      :test_unit
  
  MODELS_PATH =                 File.join('app', 'models').freeze
  MIGRATIONS_PATH =             File.join('db', 'migrate').freeze
  TESTS_PATH =                  File.join('test').freeze
  UNIT_TESTS_PATH =             File.join(TESTS_PATH, 'unit').freeze
  FIXTURES_PATH =               File.join(TESTS_PATH, 'fixtures').freeze
  FACTORY_GIRL_FACTORIES_PATH = File.join(TESTS_PATH, 'factories').freeze
  MACHINIST_FACTORIES_PATH =    File.join(TESTS_PATH, 'blueprints').freeze
  
  NON_ATTR_ARG_KEY_PREFIX =     '_'.freeze
                  
  attr_reader :indexes,
              :references,
              :test_framework
              
  def initialize(runtime_args, runtime_options = {})
    super
    
    @test_framework = DEFAULT_TEST_FRAMEWORK
    
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
      
      # Directories.
      m.directory File.join(MODELS_PATH, class_path)
      m.directory File.join(UNIT_TESTS_PATH, class_path) unless options[:skip_tests]
      m.directory File.join(FIXTURES_PATH, class_path) if options[:fixtures]
      m.directory File.join(FACTORY_GIRL_FACTORIES_PATH, class_path) if options[:factory_girl]
      m.directory File.join(MACHINIST_FACTORIES_PATH, class_path) if options[:machinist]
      
      # Model
      m.template File.join('models', 'active_record_model.rb'),
        File.join(MODELS_PATH, class_path, "#{file_name}.rb")
        
      # Model Tests.
      unless options[:skip_tests]
        m.template File.join('models', 'tests', "#{test_framework}", 'unit_test.rb'),
          File.join(UNIT_TESTS_PATH, class_path, "#{file_name}_test.rb")
      end
      
      # Fixtures/Factories.
      if options[:fixtures]
        m.template File.join('models', 'test_data', 'active_record_fixtures.yml'),
          File.join(FIXTURES_PATH, "#{file_name}.yml")
      end
      if options[:factory_girl]
        m.template File.join('models', 'test_data', 'factory_girl_factories.rb'),
          File.join(FACTORY_GIRL_FACTORIES_PATH, "#{file_name}.rb")
      end
      if options[:machinist]
        m.template File.join('models', 'test_data', 'machinist_factories.rb'),
          File.join(MACHINIST_FACTORIES_PATH, "#{file_name}.rb")
      end
      # NOTE: :object_daddy handled in model
      
      # Migration.
      unless options[:skip_migration]
        m.migration_template File.join('models', 'active_record_migration.rb') , MIGRATIONS_PATH,
          :assigns => {:migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"},
          :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end
  end
  
  protected
      
      def add_options!(opt)
        opt.separator ''
        opt.separator 'Options:'
        
        opt.on("--fixtures", "Generate fixtures.") do |v|
          options[:fixtures] = v
        end
        
        opt.on("--fgirl", "Generate \"factory_girl\" factories.") do |v|
          options[:factory_girl] = v
        end
        
        opt.on("--machinist", "Generate \"machinist\" blueprints (factories).") do |v|
          options[:machinist] = v
        end
        
        opt.on("--odaddy", "Generate \"object_daddy\" generator/factory methods.") do |v|
          options[:object_daddy] = v
        end
        
        opt.on("--skip-timestamps", "Don't add timestamps to the migration file.") do |v|
          options[:skip_timestamps] = v
        end
        
        opt.on("--skip-migration", "Skip generation of migration file.") do |v|
          options[:skip_migration] = v
        end
        
        opt.on("--skip-tests", "Skip generation of tests.") do |v|
          options[:skip_tests] = v
        end
      end
      
      def banner
        ["Usage: #{$0} #{spec.name} ModelName",
          "[field:type field:type]",
          "[_indexes:name,owner_id+owner_type,active,...]",
          "[--fixtures]",
          "[--fgirl]",
          "[--machinist]",
          "[--odaddy]",
          "[--skip_timestamps]",
          "[--skip-migration]",
          "[--skip-tests]"
        ].join(' ')
      end
      
end

module Rails
  module Generator
    class GeneratedAttribute
      def default_for_fixture
        @default ||= case type
        when :integer                     then 1
        when :float                       then 1.5
        when :decimal                     then '9.99'
        when :datetime, :timestamp, :time then Time.now.to_s(:db)
        when :date                        then Date.today.to_s(:db)
        when :string                      then 'Hello'
        when :text                        then 'Lorem ipsum dolor sit amet...'
        when :boolean                     then false
        else
          ''
        end
      end
      def default_for_factory
        @default ||= case type
        when :integer                     then 1
        when :float                       then 1.5
        when :decimal                     then '9.99'
        when :datetime, :timestamp, :time then 'Time.now'
        when :date                        then 'Date.today'
        when :string                      then '"Hello"'
        when :text                        then '"Lorem ipsum dolor sit amet..."'
        when :boolean                     then false
        else
          ''
        end
      end
    end
  end
end