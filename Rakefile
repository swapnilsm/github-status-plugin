# jpi tasks
require 'jenkins/rake'
Jenkins::Rake.new.install

# rspec tasks
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
end
