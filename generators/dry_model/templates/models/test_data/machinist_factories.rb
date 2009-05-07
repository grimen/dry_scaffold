Sham.define do
  # TODO: Define blueprint shams for "<%= class_name %>"
end

<%= class_name %>.blueprint :basic do
<% attributes.each do |attribute| -%>
  <%= attribute.name %> { <%= attribute.default_for_factory %> }
<% end -%>
end