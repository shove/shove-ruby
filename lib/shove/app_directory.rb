
module Shove

  # Used for storing and accessing shove credentials
  # from the command line utility
  class AppDirectory

    attr_accessor :apps, :app

    def initialize io=STDIN, path=File.expand_path("~/.shove.yml")
      @io = io
      @path = path
      @app = nil
      @apps = {}
      load!
    end

    def put app_id, app_key
      @apps[app_id] = app_key
      @app = app_id if @app.nil?
      save
    end

    def key app_id
      get_config(app_id)[:app_key]
    end

    def default= app_id
      unless app_id.nil?
        @app = app_id
        save
      end
    end

    def default
      @app ? get_config(@app) : get_config
    end

    def get_config app_id=nil
      config = ENV["SHOVE_ENV"] == "development" ? {
        :api_url => "http://api.shove.dev:8080",
        :ws_url => "ws://shove.dev:9000"
      } : {}

      if !@app.nil? && app_id.nil?
        config[:app_id] = @app
        config[:app_key] = key(@app)
      elsif app_id.nil? || !@apps.key?(app_id)

        puts "We need some information to continue"

        if app_id.nil?
          config[:app_id] = getinput "Enter App Id"
        else
          config[:app_id] = app_id
        end

        loop do
          config[:app_key] = getinput "Enter App Key"

          Shove.configure config
          if Shove.valid?
            puts "App Settings accepted.  Moving on..."
            break
          else
            puts "App Settings invalid, please try again"
          end
        end

        put config[:app_id], config[:app_key]
      else
        config[:app_id] = app_id
        config[:app_key] = @apps[app_id]
      end

      config
    end

    private

    def save
      File.open(@path, "w") do |f|
        f << {
          "app" => @app,
          "apps" => @apps
        }.to_yaml
      end
    end

    def getinput text
      print "#{text}: "
      @io.gets.strip
    end

    def load!
      if FileTest.exist?(@path)
        tmp = YAML.load_file(@path)
        @app = tmp["app"]
        @apps = tmp["apps"]
      end
    end

  end
end