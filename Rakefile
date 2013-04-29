# jpi tasks
#
# As of 2013-04-28, the :server task will not work. This patch fixes the issue:
#
#   https://github.com/jenkinsci/jenkins.rb/pull/76
#
require 'jenkins/rake'
Jenkins::Rake.new.install

# rspec tasks
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
end
