class CreateDucks < ActiveRecord::Migration
  def self.up
    create_table :resources, :force => true do |t|
      t.string :name
      t.text :description
      
      t.timestamps
    end
    
    add_index :resources, :name
    add_index :resources, [:name, :description]
  end
  
  def self.down
    drop_table :resources
  end
end