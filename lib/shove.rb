$:.unshift File.dirname(__FILE__)

require "rubygems"
require "net/http"
require "net/https"
require "em-http-request"
require "em-ws-client"
require "yajl"
require "yaml"
require "confstruct"
require "digest/sha1"

##
# Shove
# 
# See https://shove.io for an account and client documentation
# See https://github.com/shove/shove-ruby for gem documentation
# See https://github.com/shove/shove for js client documentation
module Shove
  
  Version = "1.0.6"
  
  class ShoveException < Exception; end
  
  class << self

    attr_accessor :config, :app

    # configure shover
    # +settings+ the settings for the created client as 
    # a string for a yaml file, or as a hash
    def configure params=nil, &block

      unless defined? @config
        @config = Confstruct::Configuration.new do
          api_url "https://api.shove.io"
        end
      end
      
      if params
        @config.configure params
      end

      if block
        @config.configure(&block)
      end

      unless defined? @app
        @app = App.new(@config)
      else
        
      end
    end

    # fetch a channel by name
    # +name+ the name of the channel
    def channel name
      @app.channel(name)
    end

    # fetch a client by id
    def client id
      @app.client(id)
    end
    
    # validate network settings
    # used for the CLI
    def valid?
      @app.valid?
    end
    
    # fetch the available stream nodes
    # for this network.
    def hosts
      @app.hosts
    end

    # Connect to the default app with a 
    # WebSocket connection
    def connect
      @app.connect
    end

    # Create a channel key
    # +channel+ the name of the channel
    def channel_key channel
      @app.channel_key channel
    end

  end
end

require "shove/app"
require "shove/app_directory"
require "shove/protocol"
require "shove/client/connection"
require "shove/client/channel"
require "shove/client/callback"
require "shove/http/request"
require "shove/http/response"
require "shove/http/channel_context"
require "shove/http/client_context"