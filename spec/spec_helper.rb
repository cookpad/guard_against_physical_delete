require 'bundler'
Bundler.setup(:default, :development)

if RUBY_VERSION >= '1.9.2'
  require 'simplecov'

  SimpleCov.start do
    add_filter "/spec/"
  end
end

require 'guard_against_physical_delete'
require 'database'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner.clean_with :deletion
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end

