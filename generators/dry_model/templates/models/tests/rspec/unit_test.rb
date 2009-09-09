require File.dirname(__FILE__) + '/../spec_helper'

describe <%= class_name %> do
  <% if options[:fixtures] -%>
    fixtures :<%= table_name %>

  <% end -%>
  it "should be valid" do
    Comment.new.should be_valid
  end
end
