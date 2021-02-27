# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "guard_against_physical_delete"
  s.version = "1.0.2"

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

  s.add_runtime_dependency "activerecord", ">= 5.0.0", "< 5.1.0"
  s.add_development_dependency "rake", "~> 13"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "sqlite3", "~> 1.3.6"
  s.add_development_dependency "bundler"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "countdownlatch"
end

