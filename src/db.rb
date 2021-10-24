require 'mysql2'

module Harvest
  module DB
    module_function

    def connect(config)
      Mysql2::Client.new config
    end

    def select_query_str(table, target: '*', conditions: nil)
      base = "SELECT #{target} FROM #{table}"
      if conditions
        base += "WHERE #{conditions.join(' ')}"
      end
      base
    end

    def insert_query_str(table, values)
      "INSERT into #{table} VALUES (#{values.join(',')})"
    end
  end
end
