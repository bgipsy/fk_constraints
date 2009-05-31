require File.dirname(__FILE__) + '/spec_helper'
require 'active_record/test_case'
require 'active_record/fixtures'

ActiveSupport::TestCase.send(:include, ActiveRecord::TestFixtures)

require File.dirname(__FILE__) + '/../init'

describe ActiveSupport::TestCase do
  include SpecHelper

  before(:all) do
    recreate_database
    setup_active_record
  end

  it "should strip fk constraints when loding fixtures by default" do
    ActiveRecord::Base.connection.should_receive(:strip_all_fk_constraints).once.with(:some_models)
    ActiveRecord::Base.connection.should_receive(:strip_all_fk_constraints).once.with(:other_models)
    ActiveSupport::TestCase.fixtures :some_models, :other_models
  end

  it "should not strip fk constraints when strip_foreign_keys_for_fixtures is unset" do
    ActiveRecord::Base.connection.should_not_receive(:strip_all_fk_constraints)
    ActiveSupport::TestCase.strip_foreign_keys_for_fixtures = false
    ActiveSupport::TestCase.fixtures :some_models, :other_models
  end
end
