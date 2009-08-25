require 'test_helper'

class <%= class_name %>Test < ActiveRecord::TestCase
  
<% if options[:fixtures] -%>
  fixtures :<%= table_name %>
  
<% end -%>
  setup do
    
  end
  
  test 'something' do
    assert true
  end
  
end
