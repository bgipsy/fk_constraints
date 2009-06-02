require 'active_record/fixtures'

module ActiveRecord::TestFixtures
  class << self
    def included_with_fk_stripping(base)
      included_without_fk_stripping(base)
      base.class_eval do
        superclass_delegating_accessor :strip_foreign_keys_for_fixtures
        self.strip_foreign_keys_for_fixtures = true
        class << self
          alias_method_chain :fixtures, :stripping_constraints
        end
      end
    end

    alias_method_chain :included, :fk_stripping
  end

  module ClassMethods
    def fixtures_with_stripping_constraints(*tables)
      tables.each {|t| ActiveRecord::Base.connection.remove_all_foreign_key_constraints(t) if t != :all} if strip_foreign_keys_for_fixtures
      fixtures_without_stripping_constraints(*tables)
    end
  end
end
