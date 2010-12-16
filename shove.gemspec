spec = Gem::Specification.new do |s|
  s.name = "shove"
  s.version = "0.1"
  s.date = "2010-12-16"
  s.summary = "Ruby gem for leveraging Shove, the real time web application"
  s.email = "dan.simpson@gmail.com"
  s.homepage = "https://github.com/shove/shover"
  s.description = "Client side implementation for the shoveapp.com API.  See http://shoveapp.com/documentation"
  s.has_rdoc = true

  s.authors = ["Dan Simpson"]

  s.files = [
    "README.md",
    "shover.gemspec",
    "Rakefile",
    "spec/helper.rb",
    "spec/shove_spec.rb",
    "lib/shove.rb",
    "lib/shove/request.rb"
  ]
end
