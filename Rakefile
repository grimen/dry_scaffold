require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

NAME = "dry_scaffold"
SUMMARY = %Q{A DRYer scaffold generator for Rails. Generates dry semantic and standards compliant views, and dry RESTful controllers.}
HOMEPAGE = "http://github.com/grimen/#{NAME}"
AUTHOR = "Jonas Grimfelt"
EMAIL = "grimen@gmail.com"
SUPPORT_FILES = %w(README.textile TODO.textile CHANGELOG.textile)

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = NAME
    gemspec.summary = SUMMARY
    gemspec.description = SUMMARY
    gemspec.homepage = HOMEPAGE
    gemspec.author = AUTHOR
    gemspec.email = EMAIL
    
    gemspec.require_paths = %w{lib}
    gemspec.files = %w(MIT-LICENSE Rakefile) << SUPPORT_FILES <<
      Dir.glob(File.join('{bin,config,generators,lib,tasks}', '**', '*').to_s)
    gemspec.executables = %w(dscaffold dry_scaffold dmodel dry_model)
    gemspec.extra_rdoc_files = SUPPORT_FILES
    
    gemspec.add_dependency 'haml'
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. " <<
    "Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

desc %Q{Run unit tests for "#{NAME}".}
task :default => :test

desc %Q{Run unit tests for "#{NAME}".}
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

desc %Q{Generate documentation for "#{NAME}".}
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = NAME
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rdoc.rdoc_files.include(SUPPORT_FILES)
  rdoc.rdoc_files.include(File.join('lib', '**', '*.rb'))
end
