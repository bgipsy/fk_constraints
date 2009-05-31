require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../init'

describe ActiveRecord::Migration do
  include SpecHelper

  class Parent < ActiveRecord::Base
    has_many :children
  end

  before(:all) do
    recreate_database
    setup_active_record

    connection.create_table :parents do |t|
      t.string :name
    end
  end

  def max_parent_id
    Parent.calculate(:max, :id) || 0
  end

  class Child < ActiveRecord::Base
    belongs_to :parent
  end

  it "should add fk constraints when creating tables" do
    connection.create_table :children do |t|
      t.string :name
      t.integer :parent_id
    end

    p = Parent.create!(:name => 'A')
    lambda { Child.create!(:name => 'B', :parent => p) }.should_not raise_error
    lambda { Child.create!(:name => 'C', :parent_id => max_parent_id + 1) }.should raise_error(ActiveRecord::StatementInvalid)
  end

  class ConstraintFreeChild < ActiveRecord::Base
    belongs_to :parent
  end

  it "should not add fk constraint when option :references => false is given" do
    connection.create_table :constraint_free_children do |t|
      t.string :name
      t.integer :parent_id , :references => false
    end

    lambda { ConstraintFreeChild.create!(:name => 'C', :parent_id => max_parent_id + 1) }.should_not raise_error
  end

  class SpecialFkChild < ActiveRecord::Base
  end

  it "should allow explicit specification of referenced table" do
    connection.create_table :special_fk_children do |t|
      t.integer :grand_parent_id, :references => :parents
    end

    p = Parent.create!(:name => 'B')
    lambda { SpecialFkChild.create!(:grand_parent_id => p.id) }.should_not raise_error
    lambda { SpecialFkChild.create!(:grand_parent_id => max_parent_id + 1) }.should raise_error(ActiveRecord::StatementInvalid)
  end

  class StrangeChild < ActiveRecord::Base
  end

  it "should allow explicit specification of REFERENCES caluse" do
    connection.add_index :parents, :name, :unique => true
    connection.create_table :strange_children do |t|
      t.string :name
      t.string :parent_name, :references => 'parents(name)'
    end
    Parent.create!(:name => 'XYZ')
    lambda { StrangeChild.create!(:parent_name => 'XYZ') }.should_not raise_error
    lambda { StrangeChild.create!(:parent_name => 'ABC') }.should raise_error(ActiveRecord::StatementInvalid)
  end

  class AddConstraintTestChild < ActiveRecord::Base
  end

  it "should allow adding fk constraints for exisitng tables" do
    connection.create_table :add_constraint_test_children do |t|
      t.integer :parent_id, :references => false
    end
    lambda { AddConstraintTestChild.create!(:parent_id => max_parent_id + 1) }.should_not raise_error
    AddConstraintTestChild.delete_all
    connection.add_foreign_key_constraint(:add_constraint_test_children, :parent_id, :parents)
    lambda { AddConstraintTestChild.create!(:parent_id => max_parent_id + 1) }.should raise_error(ActiveRecord::StatementInvalid)
  end

  class RemoveConstraintTestChild < ActiveRecord::Base
  end

  it "should allow removing fk constraints for existing tables" do
    connection.create_table :remove_constraint_test_children do |t|
      t.integer :parent_id
    end
    lambda { RemoveConstraintTestChild.create!(:parent_id => max_parent_id + 1) }.should raise_error(ActiveRecord::StatementInvalid)
    connection.remove_foreign_key_constraint(:remove_constraint_test_children, :parent_id)
    lambda { RemoveConstraintTestChild.create!(:parent_id => max_parent_id + 1) }.should_not raise_error
  end

  class MultipleConstraintTestChild < ActiveRecord::Base
  end

  it "should strip all fk constraints" do
    connection.create_table :multiple_constraint_test_children do |t|
      t.integer :parent_id
      t.string :parent_name, :references => 'parents(name)'
    end
    lambda { MultipleConstraintTestChild.create!(:parent_name => 'non-existent', :parent_id => max_parent_id + 1) }.should raise_error(ActiveRecord::StatementInvalid)
    connection.remove_all_foreign_key_constraints(:multiple_constraint_test_children)
    lambda { MultipleConstraintTestChild.create!(:parent_name => 'non_existent', :parent_id => max_parent_id + 1) }.should_not raise_error
  end

end
