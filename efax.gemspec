Gem::Specification.new do |s|
  s.name = "efax"
  s.version = "1.3.3"
  s.authors = ["Szymon Nowak", "Pawel Kozlowski", "Dr Nic Williams"]
  s.email = "szimek@gmail.com"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.homepage = "http://github.com/szimek/efax"
  s.require_path = "lib"
  s.rubygems_version = "1.3.6"
  s.summary = "Ruby library for accessing the eFax Developer service"
  s.add_runtime_dependency "builder", "~> 3.0.0"
  s.add_runtime_dependency "hpricot", "~> 0.8.1"
end
