# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "guard_against_physical_delete"
  gem.homepage = "http://github.com/cookpad/guard_against_physical_delete"
  #gem.license = "MIT"
  gem.summary = "Guard against physical delete"
  gem.description = "Guard against physical delete"
  gem.email = "morita@cookpad.com"
  gem.authors = ["MORITA shingo"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new


Dir['lib/tasks/*.rake'].each { |rake| load rake }

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc  "Run all specs with rcov"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/}
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "guard_against_delete #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
