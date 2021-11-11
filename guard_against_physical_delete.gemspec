# -*- encoding: utf-8 -*-

require_relative "lib/guard_against_physical_delete/version"

Gem::Specification.new do |s|
  s.name = "guard_against_physical_delete"
  s.version = GuardAgainstPhysicalDelete::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["MORITA shingo"]
  s.date = "2012-03-06"
  s.email = "morita@cookpad.com"
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  s.homepage = "http://github.com/cookpad/guard_against_physical_delete"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "A monkey patch for ActiveRecord to prevent physical deletion."

  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  s.add_runtime_dependency "activerecord", "~> 5"
  s.add_development_dependency "rake", "~> 13"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "sqlite3", "~> 1.4"
  s.add_development_dependency "bundler"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "countdownlatch"
end

