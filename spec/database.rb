require 'active_record'
require 'database_cleaner'

::ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => "test.db"}}
::ActiveRecord::Base.establish_connection('test')

class Logical < ::ActiveRecord::Base
  has_one :physical
  validates_length_of :name, :maximum => 5

  after_save {|record| record.after_saved = true }
end

class RemovedAtLogical < ::ActiveRecord::Base
  validates_length_of :name, :maximum => 5

  after_save {|record| record.after_saved = true }
end

class Physical < ::ActiveRecord::Base
  belongs_to :logical, :dependent => :destroy
end

class CreateAllTables < ::ActiveRecord::Migration
  def self.up
    create_table(:logicals) {|t| t.string :name; t.datetime :deleted_at; t.boolean :after_saved }
    create_table(:removed_at_logicals) {|t| t.string :name; t.datetime :removed_at; t.boolean :after_saved }
    create_table(:physicals) {|t| t.string :name; t.integer :logical_id}
  end
end
