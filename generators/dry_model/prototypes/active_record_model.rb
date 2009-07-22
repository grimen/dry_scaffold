class Duck < ActiveRecord::Base
  
  belongs_to :owner
  
  # object_daddy
  generator_for(:name) { "AString" }
  generator_for(:description) { "SomeText" }
  
end