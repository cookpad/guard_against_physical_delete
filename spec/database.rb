require 'active_record'
require 'database_cleaner'

::ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => "test.db"})

class CreateAllTables < ::ActiveRecord::Migration[5.0]
  def self.up
    create_table(:logicals) {|t| t.string :name; t.datetime :deleted_at; t.boolean :after_saved }
    create_table(:removed_at_logicals) {|t| t.string :name; t.datetime :removed_at; t.boolean :after_saved }
    create_table(:physicals) {|t| t.string :name; t.integer :logical_id}
    create_table(:parents) {|t| t.integer :children_count, :default => 0; t.integer :deleted_at_children_count, :default => 0; t.integer :removed_at_children_count, :default => 0 }
    create_table(:children) {|t| t.string :name; t.integer :parent_id }
    create_table(:deleted_at_children) {|t| t.string :name; t.integer :parent_id; t.datetime :deleted_at }
    create_table(:removed_at_children) {|t| t.string :name; t.integer :parent_id; t.datetime :removed_at }
  end
end
CreateAllTables.up unless ActiveRecord::Base.connection.data_source_exists? 'logicals'

class Logical < ::ActiveRecord::Base
  has_one :physical
  validates_length_of :name, :maximum => 5

  after_save {|record| record.after_saved = true }
end

class RemovedAtLogical < ::ActiveRecord::Base
  set_logical_delete_column :removed_at
  validates_length_of :name, :maximum => 5

  after_save {|record| record.after_saved = true }
end

class Physical < ::ActiveRecord::Base
  belongs_to :logical, :dependent => :destroy
end

class Parent < ::ActiveRecord::Base
  has_many :children
  has_many :deleted_at_children
  has_many :removed_at_children
end

class Child < ::ActiveRecord::Base
  belongs_to :parent, :counter_cache => true
end

class DeletedAtChild < ::ActiveRecord::Base
  belongs_to :parent, :counter_cache => true
end

class RemovedAtChild < ::ActiveRecord::Base
  set_logical_delete_column :removed_at
  belongs_to :parent, :counter_cache => true
end
