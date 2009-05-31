require 'rubygems'
require 'active_record'

module SpecHelper

  DB_CONFIG = {
    'adapter' => 'postgresql',
    'min_messages' => 'fatal',
    'database' => 'fk_constraints_plugin_test',
    'username' => 'postgres'}

  LOG_FILE = File.dirname(__FILE__) + '/../test.log'

  def setup_active_record
    ActiveRecord::Base.logger = Logger.new(LOG_FILE)
    ActiveRecord::Base.establish_connection(DB_CONFIG)
  end

  def recreate_database(config = DB_CONFIG)
    ActiveRecord::Base.establish_connection(config.merge('database' => 'template1'))
    ActiveRecord::Base.connection.drop_database(config['database'])
    ActiveRecord::Base.connection.create_database(config['database'])
  end

  def connection
    ActiveRecord::Base.connection
  end

end
