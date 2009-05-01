class <%= class_name %> < ActiveRecord::Base
  
<% unless references.empty? -%>
<% references.each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
  
<% end -%>
<% if options[:object_daddy] -%>
<% attributes.each do |attribute| -%>
  generator_for(:<%= attribute.name %>) { <%= attribute.default_for_factory %> }
<% end -%>
  
<% end -%>
end