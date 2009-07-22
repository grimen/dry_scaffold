class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %> do |t|
<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
      
<% unless options[:skip_timestamps] -%>
      t.timestamps
<% end -%>
    end
<% unless indexes.blank? -%>
    
<% indexes.each do |index| -%>
    add_index :<%= table_name %>, <%= index.is_a?(Array) ? "[:#{index.join(', :')}]" : ":#{index}" %>
<% end -%>
<% end -%>
  end
  
  def self.down
    drop_table :<%= table_name %>
  end
end