require 'test_helper'

class <%= class_name %>Test < ActiveRecord::TestCase
  
<% if options[:fixtures] -%>
  fixtures :<%= plural_name %>
  
<% end -%>
<% attributes.each do |attribute| -%>
  should_have_db_column :<%= attribute.name %>
<% end -%>
  
  context "A test context" do
    setup do
      
    end
    
    should 'test something' do
      assert true
    end
  end
  
end