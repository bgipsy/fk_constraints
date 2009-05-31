require 'rubygems'
require 'active_record'

require File.dirname(__FILE__) + '/../init'

DB_CONFIG = {
  :adapter => 'postgresql',
  :database => 'fk_constraints_plugin_test',
  :username => 'postgres'}.with_indifferent_access

LOG_FILE = File.dirname(__FILE__) + '/../test.log'


describe ActiveRecord::Migration do

  class Parent < ActiveRecord::Base
    has_many :children
  end

  before(:all) do
    recreate_database(DB_CONFIG)
    ActiveRecord::Base.logger = Logger.new(LOG_FILE)
    ActiveRecord::Base.establish_connection(DB_CONFIG)

    connection.create_table :parents do |t|
      t.string :name
    end
  end

  def recreate_database(config)
    ActiveRecord::Base.establish_connection(config.merge(:database => 'template1'))
    ActiveRecord::Base.connection.drop_database(config['database'])
    ActiveRecord::Base.connection.create_database(config['database'])
  end

  def connection
    ActiveRecord::Base.connection
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

  it "should allow adding fk constraints for exisitng tables"

  it "should allow removing fk constraints for existing tables"

  it "should strip fk constraints when loding fixtures by default"

  it "should not strip fk constraints when preserve_fk_constraints is set"
end
