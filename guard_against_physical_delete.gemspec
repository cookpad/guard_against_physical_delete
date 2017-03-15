# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "guard_against_physical_delete"
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["MORITA shingo"]
  s.date = "2012-03-06"
  s.description = "Guard against physical delete"
  s.email = "morita@cookpad.com"
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  s.homepage = "http://github.com/cookpad/guard_against_physical_delete"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Guard against physical delete"

  s.add_runtime_dependency "activerecord", ">= 3.0.10"
  s.add_development_dependency "rake", "< 12.0"
  s.add_development_dependency "rspec", "< 2.99"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rdoc", "~> 3.12"
  s.add_development_dependency "bundler"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "countdownlatch"
end

