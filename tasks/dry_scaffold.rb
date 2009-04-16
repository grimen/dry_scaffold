namespace :dry_scaffold do
  namespace :dependencies do
    
    GEMS = [:'josevalim-inherited_resources', :'justinfrench-formtastic', :will_paginate].freeze
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
    end
    
  end
end