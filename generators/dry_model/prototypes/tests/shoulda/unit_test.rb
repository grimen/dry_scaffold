require 'test_helper'

class DuckTest < ActiveRecord::TestCase
  
  fixtures :ducks
  
  should_have_db_column :name
  should_have_db_column :description
  
  context "A test context" do
    setup do
      
    end
    
    should 'test something' do
      assert true
    end
  end
  
end