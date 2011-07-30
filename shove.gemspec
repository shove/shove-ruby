spec = Gem::Specification.new do |s|
  s.name = "shove"
  s.version = "0.6.0"
  s.date = "2011-07-23"
  s.summary = "Ruby gem for leveraging shove.io, the web push platform"
  s.email = "dan@shove.io"
  s.homepage = "https://github.com/shove/shover"
  s.description = "Client side implementation for the shove.io API.  See http://shove.io/documentation"
  s.has_rdoc = true
  
  s.add_dependency("em-http-request", "= 0.3.0")
  s.add_dependency("commander", ">= 4.0.3")
  s.add_dependency("yajl-ruby", ">= 0.8.1")
  
  s.bindir = "bin"

  s.authors = ["Dan Simpson"]

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

end
