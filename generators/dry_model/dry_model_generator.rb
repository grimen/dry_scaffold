require 'rubygems'
begin
  require 'factory_girl'
  FACTORY_GIRL = true
rescue
  FACTORY_GIRL = false
end
begin
  require 'machinist'
  MACHINIST = true
rescue
  MACHINIST = false
end
begin
  require 'object_daddy'
  OBJECT_DADDY = true
rescue
  OBJECT_DADDY = false
end

class DryModelGenerator < Rails::Generator::NamedBase
  
  MODELS_PATH =                 File.join('app', 'models').freeze
  MIGRATIONS_PATH =             File.join('db', 'migrate').freeze
  TESTS_PATH =                  File.join('test').freeze
  UNIT_TESTS_PATH =             File.join(TESTS_PATH, 'unit').freeze
  FIXTURES_PATH =               File.join(TESTS_PATH, 'fixtures').freeze
  FACTORY_GIRL_FACTORIES_PATH = File.join(TESTS_PATH, 'factories').freeze
  MACHINIST_FACTORIES_PATH =    File.join(TESTS_PATH, 'blueprints').freeze
  
  NON_ATTR_ARG_KEY_PREFIX =     '_'.freeze
  
  default_options :fixtures => false,
                  :factory_girl => false,
                  :machinist => false,
                  :object_daddy => false,
                  :faker => false,
                  :skip_timestamps => false,
                  :skip_migration => false,
                  :skip_tests => false
                  
  attr_reader :indexes,
              :references
              
  def initialize(runtime_args, runtime_options = {})
    super
    
    @attributes ||= []
    args_for_model = []
    
    @args.each do |arg|
      arg_entities = arg.split(':')
      if arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}index/
        arg_indexes = arg_entities[1].split(',').compact.uniq
        @indexes = arg_indexes.collect do |index|
          if index =~ /\+/
            index.split('+').collect { |i| i.downcase.to_sym  }
          else
            index.downcase.to_sym
          end
        end
      else
        @attributes << Rails::Generator::GeneratedAttribute.new(*arg_entities)
        args_for_model << arg
      end
    end
    @args = args_for_model
    @references = attributes.select(&:reference?)
  end
  
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_name, "#{class_name}"
      m.class_collisions class_name, "#{class_name}Test"
      
      # Directories.
      m.directory File.join(MODELS_PATH, class_path)
      m.directory File.join(UNIT_TESTS_PATH, class_path) unless options[:skip_tests]
      m.directory File.join(FIXTURES_PATH, class_path) if options[:fixtures]
      m.directory File.join(FACTORY_GIRL_FACTORIES_PATH, class_path) if options[:factory_girl]
      m.directory File.join(MACHINIST_FACTORIES_PATH, class_path) if options[:machinist]
      
      # Model Class + Unit Test.
      m.template 'model_standard.rb', File.join(MODELS_PATH, class_path, "#{file_name}.rb")
      m.template 'unit_test_standard.rb', File.join(UNIT_TESTS_PATH, class_path, "#{file_name}_test.rb")
      
      # Fixtures/Factories.
      m.template 'fixtures_standard.yml',
        File.join(FIXTURES_PATH, "#{file_name}.yml") if options[:fixtures]
      m.template 'factories_factory_girl.rb',
        File.join(FACTORY_GIRL_FACTORIES_PATH, "#{file_name}.rb") if options[:factory_girl]
      m.template 'factories_machinist.rb',
        File.join(MACHINIST_FACTORIES_PATH, "#{file_name}.rb") if options[:machinist]
      
      # Migration.
      unless options[:skip_migration]
        m.migration_template 'migration_standard.rb', MIGRATIONS_PATH, :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
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
        
        opt.on("--machinist", "Generate \"machinist\" blueprints (factories).") do |v|
          options[:machinist] = v
        end
        
        opt.on("--factory_girl", "Generate \"factory_girl\" factories.") do |v|
          options[:factory_girl] = v
        end
        
        opt.on("--object_daddy", "Generate \"object_daddy\" generator/factory methods to this model.") do |v|
          options[:object_daddy] = v
        end
        
        opt.on("--skip-timestamps", "Don't add timestamps to the migration file for this model.") do |v|
          options[:skip_timestamps] = v
        end
        
        opt.on("--skip-migration", "Don't generate a migration file for this model.") do |v|
          options[:skip_migration] = v
        end
        
        opt.on("--skip-tests", "Don't generate a migration file for this model.") do |v|
          options[:skip_tests] = v
        end
      end
      
      def banner
        ["Usage: #{$0} #{spec.name} ModelName",
          "[field:type field:type]",
          "[_index:name,owner_id+owner_type,active...]",
          "[--fixtures]",
          "[--factory_girl]",
          "[--machinist]",
          "[--object_daddy]",
          "[--skip_timestamps]",
          "[--skip-migration]",
          "[--skip-tests]"
        ].join(' ')
      end
      
end

module Rails
  module Generator
    class GeneratedAttribute
      def default_for_factory
        @default ||= case type
        when :integer                     then 1
        when :float                       then 1.5
        when :decimal                     then '9.99'
        when :datetime, :timestamp, :time then 'Time.now'
        when :date                        then 'Date.today'
        when :string                      then '"Hello"'
        when :text                        then '"SomeText"'
        when :boolean                     then false
        else
          ''
        end
      end
    end
  end
end