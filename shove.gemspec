spec = Gem::Specification.new do |s|
  s.name = "shove"
  s.version = "1.0.2"
  s.date = "2012-02-08"
  s.summary = "Ruby gem for leveraging shove.io, the web push platform"
  s.email = "dan@shove.io"
  s.homepage = "https://github.com/shove/shove-ruby"
  s.description = "Client side implementation for the shove.io API.  See http://shove.io/documentation"
  s.has_rdoc = true
  
  s.add_dependency("em-http-request", ">= 1.0.0")
  s.add_dependency("em-ws-client", ">= 0.1.2")
  s.add_dependency("yajl-ruby", ">= 1.1.0")
  s.add_dependency("confstruct", ">= 0.2.1")
  
  s.bindir = "bin"
  s.authors = ["Dan Simpson"]

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

end
