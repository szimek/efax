require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "efax"
    gem.summary = 'Ruby library for accessing the eFax Developer service'
    gem.authors = ["Szymon Nowak", "Pawel Kozlowski", "Dr Nic Williams"]
    gem.email = "szimek@gmail.com"
    gem.homepage = "http://github.com/szimek/efax"
    gem.rubyforge_project = "efax"

    gem.add_dependency('hpricot', '>= 0.8.1')
    gem.add_development_dependency('test-unit', '~> 2')
    gem.add_development_dependency('mocha', '>= 0.9')
  end

  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

Rake::RDocTask.new do |rdoc|
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
