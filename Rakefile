require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Generate the README HTML"
task :readme do

  require "redcarpet"
  require "albino"

  # Create a custom renderer that uses albino to
  # make pretty code
  class Colorizer < Redcarpet::Render::HTML
    def block_code(code, language)
      Albino.colorize(code, language)
    end
  end

  content = Redcarpet::Markdown.new(Colorizer, :fenced_code_blocks => true)
    .render(File.read("README.markdown"))

  File.open("README.html", "w") do |f|
    f << content
  end

end
