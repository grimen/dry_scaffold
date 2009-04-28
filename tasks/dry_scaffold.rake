namespace :dry_scaffold do
  
  desc "Setup for this plugin/gem."
  task :setup => :environment do
    Rake::Task['dry_scaffold:dependencies:install'].invoke
  end
  
  namespace :dependencies do
    
    GEMS = [:haml, :will_paginate, :'josevalim-inherited_resources', :'justinfrench-formtastic'].freeze
    PLUGINS = [].freeze
    
    puts "---------------------------------------"
    puts " Setup"
    puts "---------------------------------------"
    
    desc "Install dependencies for fully advantage of this generator."
    task :install => :environment do
      puts "GEMS: #{GEMS.to_sentence}" unless GEMS.empty?
      GEMS.each do |gem|
        puts `sudo gem install #{gem}`
      end
      
      puts "PLUGINS: #{PLUGINS.to_sentence}" unless PLUGINS.empty?
      PLUGINS.each do |plugin|
        puts `./script/plugin install #{plugin}`
      end
      
      puts "Setup HAML for this project..."
      #puts `haml --rails .`
      
      puts "---------------------------------------"
      puts " Configuration"
      puts "---------------------------------------"
      puts "Update your environment config: 'config/environments/development.rb' <<<"
      GEMS.each do |gem|
        gem_info = gem.to_s.split('-')
        if gem_info.size > 1
          gem_owner = gem_info[0]
          gem_lib = gem_info[1]
          puts "  config.gem '#{gem_owner}-#{gem_lib}', :lib => '#{gem_lib}'"
        else
          gem_lib = gem_info[0]
          puts "  config.gem '#{gem_lib}'"
        end
      end
      puts "<<<"
    end
    
  end
end