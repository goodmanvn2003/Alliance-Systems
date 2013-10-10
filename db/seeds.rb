# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
ActiveRecord::Base.establish_connection
case ActiveRecord::Base.connection.adapter_name
  when 'SQLite'
    # SQLite
    ActiveRecord::Base.connection.execute("DELETE FROM roles")
    ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name = 'roles'")
  when 'MySQL'
    # MySQL
    ActiveRecord::Base.connection.execute("TRUNCATE roles")
  when 'PostgreSQL'
    # PostgreSQL
    ActiveRecord::Base.connection.execute("TRUNCATE roles")
  else
    raise '[Err] unsupported database adapter'
end

Role.create({
                :name => 'admin'
            })
Role.create({
                :name => 'developer'
            })
Role.create({
                :name => 'contentadmin'
            })
Role.create({
                :name => 'user'
            })