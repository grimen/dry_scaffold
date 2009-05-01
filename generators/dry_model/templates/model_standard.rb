class <%= class_name %> < ActiveRecord::Base
  
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
  
<% if options[:object_daddy] -%>
<% attributes.select(&:reference?).each do |attribute| -%>
  generator_for(:<%= attribute.name) { <%= attribute.default %> }
<% end -%>
  
<% end -%>
end