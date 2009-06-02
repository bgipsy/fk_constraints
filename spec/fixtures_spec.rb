require File.dirname(__FILE__) + '/spec_helper'

RAILS_ENV = "test"

require File.dirname(__FILE__) + '/../init'

ActiveSupport::TestCase.send(:include, ActiveRecord::TestFixtures)

describe ActiveSupport::TestCase do
  include SpecHelper

  before(:all) do
    recreate_database
    setup_active_record
  end

  it "should strip fk constraints when loding fixtures by default" do
    ActiveRecord::Base.connection.should_receive(:remove_all_foreign_key_constraints).once.with(:some_models)
    ActiveRecord::Base.connection.should_receive(:remove_all_foreign_key_constraints).once.with(:other_models)
    ActiveSupport::TestCase.fixtures :some_models, :other_models
  end

  it "should not strip fk constraints when strip_foreign_keys_for_fixtures is unset" do
    ActiveRecord::Base.connection.should_not_receive(:remove_all_foreign_key_constraints)
    ActiveSupport::TestCase.strip_foreign_keys_for_fixtures = false
    ActiveSupport::TestCase.fixtures :some_models, :other_models
  end
end
