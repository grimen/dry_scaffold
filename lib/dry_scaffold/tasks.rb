require 'rubygems'
require 'rake'

# Make tasks visible for Rails also when used as gem.
load File.expand_path(File.join(File.dirname(__FILE__), *%w(.. .. tasks dry_scaffold.rake)))