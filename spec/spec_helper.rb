require 'bundler'
Bundler.setup

require 'database'
require 'guard_against_physical_delete'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:suite) do
    CreateAllTables.up unless ActiveRecord::Base.connection.table_exists? 'logicals'
    DatabaseCleaner.clean_with :deletion
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end

