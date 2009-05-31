require 'active_record/connection_adapters/postgresql_adapter'

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def add_foreign_key_constraint(table_name, column_name, referenced_table_name, referenced_column_name = 'id')
    execute "ALTER TABLE #{table_name} ADD FOREIGN KEY (#{column_name}) REFERENCES #{referenced_table_name}(#{referenced_column_name})"
  end

  def remove_foreign_key_constraint(table_name, column_name)
    execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{foreign_key_constraint_name(table_name, column_name)}"
  end

  def foreign_key_constraint_name(table_name, column_name)
    select_value("SELECT conname FROM pg_constraint JOIN pg_attribute ON (attrelid=conrelid AND ARRAY[attnum] <@ conkey) WHERE " +
      "conrelid='#{table_name}'::regclass::oid AND contype='f' AND attname='#{column_name}'")
  end
  
  def add_column_options_with_foreign_key_constraints!(sql, options)
    add_column_options_without_foreign_key_constraints!(sql, options)
    return if options[:column].options[:references] == false
    referenced_table = options[:column].options[:references] || referenced_table_name(options[:column].name.to_s)
    sql << " REFERENCES #{referenced_table.to_s}" if referenced_table
  end
  
  alias_method_chain :add_column_options!, :foreign_key_constraints

  def strip_all_foreign_key_constraints(table_name)
    all_foreign_key_constraints_for(table_name).each {|c| drop_fk_constraint(table_name, c)}
  end

  def all_foreign_key_constraints_for(table_name)
    select_values("SELECT conname FROM pg_constraint WHERE " +
      "conrelid='#{table_name}'::regclass::oid AND contype='f'")
  end

  def drop_fk_constraint(table_name, constraint_name)
    execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{constraint_name}"
  end
end

class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def referenced_table_name(column_name)
    $1.pluralize if column_name =~ /^(.*)_id$/
  end
end

# Who would imagine that options can be handy for the adapter?

class ActiveRecord::ConnectionAdapters::ColumnDefinition
  attr_accessor :options
end

class ActiveRecord::ConnectionAdapters::TableDefinition
  def column_with_option_preserving(name, type, options = {})
    result = column_without_option_preserving(name, type, options)
    self[name].options = options
    result
  end
  
  alias_method_chain :column, :option_preserving
end
