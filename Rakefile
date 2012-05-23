require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :autospec => :spec do
  require "eventmachine"
  
  $time = Time.now

  module Handler
    def file_modified
      if Time.now - $time > 1
        $time = Time.now
        Rake::Task["spec"].execute
      end
    end
  end

  EM.kqueue = true if EM.kqueue?
  EM.run do
    ["spec","lib"].collect { |dir|
      Dir.glob(File.dirname(__FILE__) + "/#{dir}/**/*.rb")
    }.flatten.each do |file|  
      EM.watch_file file, Handler
    end
  end
  
end
