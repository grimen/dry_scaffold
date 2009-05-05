class Resource < ActiveRecord::Base
  
  belongs_to :user
  
  # object_daddy
  generator_for(:name) { "AString" }
  generator_for(:description) { "SomeText" }
  
end