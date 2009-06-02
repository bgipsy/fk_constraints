require File.dirname(__FILE__) + '/lib/fk_constraints'

if RAILS_ENV == "test"
  require File.dirname(__FILE__) + '/lib/fk_constraints_fixtures'
end
