namespace :dry_scaffold do
  
  GEM_ROOT = File.join(File.dirname(__FILE__), '..').freeze
  
  desc "Setup for this plugin/gem."
  task :setup => :environment do
    Rake::Task['dry_scaffold:dependencies:install'].invoke
    Rake::Task['dry_scaffold:config:generate'].invoke
  end
  
  namespace :config do
    
    desc "Generate a dry_scaffold config file as 'RAILS_ROOT/config/scaffold.yml'"
    task :generate do
      template = File.join(GEM_ROOT, 'config', 'scaffold.yml')
      to_file = File.join(Rails.root, 'config', 'scaffold.yml')
      
      `cp #{template} #{to_file}`
      
      if  File.exists?(to_file)
        puts "Generated config file: '#{to_file}'"
      else
        puts "Could not create the config file. Hint: Try with sudo." 
      end
    end
    
  end
  
  namespace :dependencies do
    
    require File.join(GEM_ROOT, 'lib', 'setup_helper')
    include SetupHelper
    
    GEMS = [:haml,
            :'mislav-will_paginate',
            :'josevalim-inherited_resources',
            :'justinfrench-formtastic',
            :'thoughtbot-shoulda'].freeze
    PLUGINS = [].freeze
    
    desc "Install dependencies for fully advantage of this generator."
    task :install => :environment do
      
      puts "---------------------------------------"
      puts " Dependencies"
      puts "---------------------------------------"
      puts "Installing gems..."
      
      # Install gems
      unless GEMS.empty?
        puts "GEMS: #{GEMS.to_sentence}" 
        GEMS.each do |gem|
          puts `sudo gem install #{gem} --no-ri`
        end
      end
      
      # Install plugins
      unless PLUGINS.empty?
        puts "PLUGINS: #{PLUGINS.to_sentence}"
        puts "Installing plugins..."
        PLUGINS.each do |plugin|
          puts `./script/plugin install #{plugin}`
        end
      end
      
      # Setup HAML - if missing
      unless File.directory?(File.join(Rails.root, 'vendor', 'plugins', 'haml'))
        puts "Initializing HAML for this project..."
        puts `haml --rails #{Rails.root}`
      end
      
      # Add gems to Rails environment with gems - if missing
      config_gems File.join(Rails.root, 'config', 'environment.rb'), GEMS
      
      puts "---------------------------------------"
      puts " Configuration"
      puts "---------------------------------------"
      puts "Adding configuration..."
      puts "File 'config/environments/development.rb' now contains (added automatically):"
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
      puts "---------------------------------------"
    end
    
  end
end