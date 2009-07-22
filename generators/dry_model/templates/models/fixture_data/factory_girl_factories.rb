Factory.define :<%= singular_name %>, :class => <%= class_name %> do |f|
<% attributes.each do |attribute| -%>
  f.<%= attribute.name %> "<%= attribute.default_for_factory %>"
<% end -%>
end