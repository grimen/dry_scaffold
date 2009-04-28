module SetupHelper
  
  # Add gem configuration to a specified Rails environment file
  def config_gems(config_file, gems)
    sentinel = 'Rails::Initializer.run do |config|'
    config_line = ''
    
    gems.each do |gem|
      gem_info = gem.to_s.split('-')
      if gem_info.size > 1
        gem_owner = gem_info[0]
        gem_lib = gem_info[1]
        config_line = "config.gem '#{gem_owner}-#{gem_lib}', :lib => '#{gem_lib}'"
      else
        gem_lib = gem_info[0]
        config_line = "config.gem '#{gem_lib}'"
      end
      
      gsub_file_if_missing config_file, /(#{Regexp.escape(sentinel)})/mi, config_line do |match|
        "#{match}\n  #{config_line}"
      end
    end
  end
  
  # Add info to specified file and beneath specified regex if the expression don't exist in the file.
  def gsub_file_if_missing(path, regexp, new_exp, *args, &block)
    existing_content = File.read(path)
    unless existing_content =~ /(#{new_exp.strip}|#{new_exp.strip.tr('\'', '\"')})/
      content = File.read(path).gsub(regexp, *args, &block)
    else
      content = existing_content
    end
    File.open(path, 'wb') { |file| file.write(content) }
  end
  
end