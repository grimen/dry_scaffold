namespace :dry_scaffold do
  
  desc "Setup for this plugin/gem."
  task :setup do
    Rake.invoke['dry_scaffold:dependencies:install']
  end
  
  namespace :dependencies do
    
    GEMS = [:haml, :'josevalim-inherited_resources', :'justinfrench-formtastic', :will_paginate].freeze
    PLUGINS = [].freeze
    
    desc "Install dependencies for fully advantage of this generator."
    task :install do
      puts "GEMS: #{GEMS.to_sentence}" unless GEMS.empty?
      GEMS.each do |gem|
        `sudo gem install #{gem}`
      end
      puts "PLUGINS: #{PLUGINS.to_sentence}" unless PLUGINS.empty?
      PLUGINS.each do |plugin|
        `./script/plugin install #{plugin}`
      end
      `haml --rails .`
    end
    
  end
end