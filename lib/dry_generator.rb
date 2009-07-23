class DryGenerator < Rails::Generator::NamedBase
  
  HAS_WILL_PAGINATE =         defined?(WillPaginate)
  HAS_FORMTASTIC =            defined?(Formtastic)
  HAS_INHERITED_RESOURCES =   defined?(InheritedResources)
  HAS_SHOULDA =               defined?(Shoulda)
  
  # Load defaults from config file - default or custom.
  begin
    default_config_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'scaffold.yml'))
    custom_config_file = File.expand_path(File.join(Rails.root, 'config', 'scaffold.yml'))
    config_file = File.join(File.exist?(custom_config_file) ? custom_config_file : default_config_file)
    config = YAML::load(File.open(config_file))
    
    CONFIG_ARGS = config['dry_scaffold']['args'] rescue nil
    CONFIG_OPTIONS = config['dry_scaffold']['options'] rescue nil
  end
  
  # Banner: Generator arguments and options.
  BANNER_ARGS = [
      "[field:type field:type ...]"
    ].freeze
  BANNER_OPTIONS = [
      "[--skip-tests]",
      "[--shoulda]",
      "[--fixtures]",
      "[--fgirl]",
      "[--machinist]",
      "[--odaddy]"
    ].freeze
    
  DEFAULT_ARGS = {
      :actions => (CONFIG_ARGS['actions'].split(',').compact.uniq.collect { |v| v.downcase.to_sym } rescue nil),
      :formats => (CONFIG_ARGS['formats'].split(',').compact.uniq.collect { |v| v.downcase.to_sym } rescue nil)
    }.freeze
    
  DEFAULT_OPTIONS = {
      :resourceful      => CONFIG_OPTIONS['resourceful']  || HAS_INHERITED_RESOURCES,
      :formtastic       => CONFIG_OPTIONS['formtastic']   || HAS_FORMTASTIC,
      :pagination       => CONFIG_OPTIONS['pagination']   || HAS_WILL_PAGINATE,
      :skip_tests       => !CONFIG_OPTIONS['tests']       || false,
      :skip_helpers     => !CONFIG_OPTIONS['helpers']     || false,
      :skip_views       => !CONFIG_OPTIONS['views']       || false,
      :layout           => CONFIG_OPTIONS['layout']       || false,
      :fixtures         => CONFIG_OPTIONS['fixtures']     || false,
      :fgirl            => CONFIG_OPTIONS['factory_girl'] || false,
      :machinist        => CONFIG_OPTIONS['machinist']    || false,
      :odaddy           => CONFIG_OPTIONS['object_daddy'] || false,
      :tunit            => CONFIG_OPTIONS['test_unit']    || true,
      :shoulda          => CONFIG_OPTIONS['shoulda']      || false
    }.freeze
  
  TEST_PATHS = {
      :test_unit        => 'test',
      :shoulda          => 'test'
    }.freeze
    
  DEFAULT_TEST_FRAMEWORK =      :test_unit
  DEFAULT_FACTORY_FRAMEWORK =   :fixtures
  
  TESTS_PATH =                  File.join('test').freeze
  FUNCTIONAL_TESTS_PATH =       File.join(TESTS_PATH, 'functional').freeze
  UNIT_TESTS_PATH =             File.join(TESTS_PATH, 'unit').freeze
  
  NON_ATTR_ARG_KEY_PREFIX =     '_'.freeze
  
  attr_accessor :view_template_format,
                :test_framework,
                :factory_framework
  
  def initialize(runtime_args, runtime_options = {})
    super(runtime_args, runtime_options)
    
    @test_framework = options[:test_framework] || DEFAULT_TEST_FRAMEWORK
  end
  
  protected
    
    def symbol_array_to_expression(array)
      ":#{array.compact.join(', :')}" if array.present?
    end
    
    def banner_args
      BANNER_ARGS.join(' ')
    end
    
    def banner_options
      BANNER_OPTIONS.join(' ')
    end
    
    def banner
      "\nUsage: \n\n#{$0} #{spec.name} MODEL_NAME"
    end
    
    def add_options!(opt)
      opt.separator ' '
      opt.separator 'Scaffold + Model Options:'
      
      opt.on('--skip-tests', "Test: Skip generation of tests.") do |v|
        options[:skip_tests] = v
      end
      
      opt.on("--tunit", "Test: Generate \"test_unit\" tests. Note: Rails default.") do |v|
        options[:test_unit] = v
        options[:test_framework] = :test_unit
      end
      
      opt.on("--shoulda", "Test: Generate \"shoulda\" tests.") do |v|
        options[:shoulda] = v
        options[:test_framework] = :shoulda
      end
      
      #opt.on('--rspec', "Test: Generate \"rspec\" tests.") do |v|
      #  # TODO: Implement RSpec templates. Maybe.
      #  puts '[dry_scaffold:] RSpec currently not supported.'
      #  options[:rspec] = v
      #  options[:test_framework] = :rspec
      #end
      
      opt.on("--fixtures", "Test: Generate fixtures. Note: Rails default.") do |v|
        options[:fixtures] = v
        options[:factory_framework] = :fixtures
      end
      
      opt.on("--fgirl", "Test: Generate \"factory_girl\" factories.") do |v|
        options[:factory_girl] = v
        options[:factory_framework] = :factory_girl
      end
      
      opt.on("--machinist", "Test: Generate \"machinist\" blueprints (factories).") do |v|
        options[:machinist] = v
        options[:factory_framework] = :machinist
      end
      
      opt.on("--odaddy", "Test: Generate \"object_daddy\" generator/factory methods.") do |v|
        options[:object_daddy] = v
        options[:factory_framework] = :object_daddy
      end
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
