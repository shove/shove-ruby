$:.unshift File.dirname(__FILE__)

require "rubygems"
require "net/http"
require "em-http-request"
require "em-ws-client"
require "yajl"
require "confstruct"
require "yaml"

##
# Shove
# 
# See http://shove.io for an account and client documentation
# See https://github.com/shove/shover for gem documentation
# See https://github.com/shove/shove for client documentation
module Shove
  
  Version = "1.0.1"
  
  class ShoveException < Exception; end
  
  class << self

    attr_accessor :config, :app

    # configure shover
    # +settings+ the settings for the created client as 
    # a string for a yaml file, or as a hash
    def configure &block

      unless defined? @config
        @config = Confstruct::Configuration.new do
          api_url "https://api.shove.io/"
        end
      end

      @config.configure &block

      unless defined? @app
        @app = App.new(@config)
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

  end
end

require "shove/app"
require "shove/client"
require "shove/http/request"
require "shove/http/response"
require "shove/http/channel_context"
require "shove/http/client_context"