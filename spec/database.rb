require 'active_record'
require 'database_cleaner'

::ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:shared'}}
::ActiveRecord::Base.establish_connection('test')

class Logical < ::ActiveRecord::Base
  has_one :physical
end

class RemovedAtLogical < ::ActiveRecord::Base

end

class Physical < ::ActiveRecord::Base
  belongs_to :logical, :dependent => :destroy
end

class CreateAllTables < ::ActiveRecord::Migration
  def self.up
    create_table(:logicals) {|t| t.string :name; t.datetime :deleted_at }
    create_table(:removed_at_logicals) {|t| t.string :name; t.datetime :removed_at }
    create_table(:physicals) {|t| t.string :name; t.integer :logical_id}
  end
end
