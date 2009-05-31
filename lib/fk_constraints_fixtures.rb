module ActiveRecord::FkConstraintsFixtures
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      superclass_delegating_accessor :strip_foreign_keys_for_fixtures
      self.strip_foreign_keys_for_fixtures = true
      class << self
        alias_method_chain :fixtures, :stripping_constraints
      end
    end
  end

  module ClassMethods
    def fixtures_with_stripping_constraints(*tables)
      tables.each {|t| ActiveRecord::Base.connection.strip_all_fk_constraints(t)} if strip_foreign_keys_for_fixtures
      fixtures_without_stripping_constraints(*tables)
    end
  end
end

ActiveSupport::TestCase.send(:include, ActiveRecord::FkConstraintsFixtures)
