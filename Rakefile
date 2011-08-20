require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

desc "Default: run all tests"
task :default => [:test]
