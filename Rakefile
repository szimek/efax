require 'rubygems'
require 'bundler/setup'
require 'rdoc/task'
require 'rake/testtask'

RDoc::Task.new do |rdoc|
  files =['README.rdoc', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.rdoc" # page to start on
  rdoc.title = 'eFax: Ruby library for accessing the eFax Developer service'
  rdoc.rdoc_dir = 'rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

desc "Default: run all tests"
task :default => [:test]
