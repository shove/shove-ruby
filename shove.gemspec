spec = Gem::Specification.new do |s|
  s.name = "shove"
  s.version = "0.52"
  s.date = "2011-03-26"
  s.summary = "Ruby gem for leveraging shove.io, the web push platform"
  s.email = "dan@shove.io"
  s.homepage = "https://github.com/shove/shover"
  s.description = "Client side implementation for the shove.io API.  See http://shove.io/documentation"
  s.has_rdoc = true
  
  s.add_dependency("em-http-request", "= 0.3.0")
  s.add_dependency("commander", ">= 4.0.3")
  s.add_dependency("yajl-ruby", ">= 0.8.1")
  
  s.bindir = "bin"
	s.executables = ["shove"]
	
  s.authors = ["Dan Simpson"]

  s.files = [
    "README.md",
    "shove.gemspec",
    "Rakefile",
    "spec/helper.rb",
    "spec/shove_spec.rb",
    "lib/shove.rb",
    "lib/shove/request.rb",
    "lib/shove/response.rb",
    "lib/shove/client.rb",
    "bin/shove"
  ]
end
