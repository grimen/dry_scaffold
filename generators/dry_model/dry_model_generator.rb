class DryModelGenerator < Rails::Generator::NamedBase
  
  MODELS_PATH =                 File.join('app', 'models').freeze
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
                  :skip_timestamps => false,
                  :skip_migration => false,
                  :skip_tests => false
                  
  attr_reader :indexes
  
  def initialize(runtime_args, runtime_options = {})
    super
    
    @args.each do |arg|
      arg_entities = arg.split(':')
      if arg =~ /^#{NON_ATTR_ARG_KEY_PREFIX}index/
        arg_indexes = arg_entities[1].split(',').compact.uniq
        @indexes = arg_indexes.collect do |index|
          if index =~ /\+/
            index.split('+').collect { |index_entity| index_entity.downcase.to_sym  }
          else
            index.downcase.to_sym
          end
        end
        @indexes = arg_indexes.collect { |index| index.downcase.to_sym }
      end
    end
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
      m.directory File.join(FACTORY_GIRL_PATH, class_path) if options[:factory_girl]
      m.directory File.join(MACHINIST_PATH, class_path) if options[:machinist]
      
      # Model Class + Unit Test.
      m.template 'model.rb', File.join(MODELS_PATH, class_path, "#{file_name}.rb")
      m.template 'unit_test.rb', File.join(UNIT_TESTS_PATH, class_path, "#{file_name}_test.rb")
      
      # Fixtures/Factories.
      m.template 'fixtures_standard.yml',
        File.join(FIXTURES_PATH, "#{file_name}.yml") if options[:fixtures]
      m.template 'factories_factory_girl.rb',
        File.join(FACTORY_GIRL_FACTORIES_PATH, "#{file_name}.rb") if options[:factory_girl]
      m.template 'factories_machinist.rb',
        File.join(MACHINIST_FACTORIES_PATH, "#{file_name}.rb") if options[:machinist]
      
      # Migration.
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end
  end
  
  protected
      
      def banner
        "Usage: #{$0} #{spec.name} ModelName [field:type field:type]"
      end
      
      def add_options!(opt)
        opt.separator ''
        opt.separator 'Options:'
        
        opt.on("--fixtures", "Generate fixtures.") do |v|
          options[:fixtures] = v
        end
        
        opt.on("--machinist", "Generate machinist blueprints (factories).") do |v|
          options[:fixtures] = v
        end
        
        opt.on("--factory_girl", "Generate factory_girl factories.") do |v|
          options[:fixtures] = v
        end
        
        opt.on("--object_daddy", "Generate object_daddy generator methods to the model (i.e. factories behaviour).") do |v|
          options[:fixtures] = v
        end
        
        opt.on("--skip-timestamps", "Don't add timestamps to the migration file for this model") do |v|
          options[:skip_timestamps] = v
        end
        
        opt.on("--skip-migration", "Don't generate a migration file for this model") do |v|
          options[:skip_migration] = v
        end
        
        opt.on("--skip-tests", "Don't generate a migration file for this model") do |v|
          options[:skip_tests] = v
        end
      end
      
end