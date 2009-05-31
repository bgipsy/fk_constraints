require 'rubygems'
require 'active_record'

DB_CONFIG = {
  :adapter => 'postgresql',
  :database => 'fk_constraints_plugin_test',
  :username => 'postgres'}.with_indifferent_access

MIGRATIONS_PATH = File.dirname(__FILE__) + '/fixtures/migrate'
LOG_FILE = File.dirname(__FILE__) + '/../test.log'


describe ActiveRecord::Migration do
  before(:all) do
    recreate_database(DB_CONFIG)
    ActiveRecord::Base.logger = Logger.new(LOG_FILE)
    ActiveRecord::Base.establish_connection(DB_CONFIG)
  end

  def recreate_database(config)
    ActiveRecord::Base.establish_connection(config.merge(:database => 'template1'))
    ActiveRecord::Base.connection.drop_database(config['database'])
    ActiveRecord::Base.connection.create_database(config['database'])
  end

  class Parent < ActiveRecord::Base
    has_many :children
  end

  class Child < ActiveRecord::Base
    belongs_to :parent
  end

  it "test should at least run migrations" do
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate(MIGRATIONS_PATH, nil)
    m = Parent.new(:name => 'A')
    m.children.build(:name => 'B')
    m.save.should be_true
    Parent.count.should == 1
    Child.count.should == 1
  end

  it "should add fk constraints when creating tables"

  it "should not add fk constraint when option :references => false is given"

  it "should allow explicit specification of referenced table"

  it "should allow explicit specification of REFERENCES caluse"

  it "should allow adding fk constraints for exisitng tables"

  it "should allow removing fk constraints for existing tables"

  it "should strip fk constraints when loding fixtures by default"

  it "should not strip fk constraints when preserve_fk_constraints is set"
end
