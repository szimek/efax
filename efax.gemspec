# -*- encoding: utf-8 -*-
require File.expand_path('../lib/efax/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Szymon Nowak", "Pawel Kozlowski", "Dr Nic Williams"]
  gem.email         = ["szimek@gmail.com"]
  gem.description   = %q{Ruby library for accessing the eFax Developer service}
  gem.summary       = %q{Ruby library for accessing the eFax Developer service}
  gem.homepage      = "http://github.com/szimek/efax"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "efax"
  gem.require_paths = ["lib"]
  gem.version       = EFax::VERSION

  gem.add_runtime_dependency "builder", "~> 3.0.0"
  gem.add_runtime_dependency "hpricot", "~> 0.8.1"

  gem.add_development_dependency "test-unit", "~> 2.3.2"
  gem.add_development_dependency "mocha", "~> 0.9.12"
end
