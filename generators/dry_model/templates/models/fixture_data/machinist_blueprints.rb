Sham.define do
  
end

<%= class_name %>.blueprint do
<% attributes.each do |attribute| -%>
  <%= attribute.name %> { <%= attribute.default_for_factory %> }
<% end -%>
end