# guard_against_physical_delete

[![test](https://github.com/cookpad/guard_against_physical_delete/actions/workflows/test.yml/badge.svg)](https://github.com/cookpad/guard_against_physical_delete/actions/workflows/test.yml)

[![Gem Version](https://badge.fury.io/rb/guard_against_physical_delete.svg)](https://rubygems.org/gems/guard_against_physical_delete)

A monkey patch for ActiveRecord to prevent physical deletion.

## Installation

Add this line to your Rails application's Gemfile:

```ruby
gem 'guard_against_physical_delete'
```

And then execute:

```shell
bundle install
```

## Usage

If there is a record with a column named `deleted_at`,
an exception is automatically raised on the methods that are likely to perform physical deletion.

```ruby
# This will raise `GuardAgainstPhysicalDelete::PhysicalDeleteError`.
user.delete

# To allow phsycal deletion, do it in `physical_delete { ... }` block.
user.class.physical_delete do
  user.delete
end
```

### Configuration

If you want to use a column name other than `deleted_at`,
you can change it as follows:

```ruby
class User < ApplicationRecord
  self.logical_delete_column = :removed_at
end
```

## License

This gem is available as open source under the terms of the MIT License.
See [License.txt](/License.txt) for more details.
