class CreateTestTables < ActiveRecord::Migration
  def self.up
    create_table :parents do |t|
      t.string :name
    end

    create_table :children do |t|
      t.string :name
      t.integer :parent_id
    end
  end
end
