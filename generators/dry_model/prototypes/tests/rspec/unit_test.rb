require File.dirname(__FILE__) + '/../spec_helper'

describe DuckTest do
  fixtures :ducks
  
  it "should be valid" do
    DuckTest.new.should be_valid
  end
end
