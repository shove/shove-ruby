$:.unshift File.dirname(__FILE__)

require "rubygems"
require "eventmachine"
require "em-http"
require "yaml"
require "json"

##
# Shove
# 
# See http://shove.io for an account
module Shove
  
  Version = 0.2
  
  class << self
  
    attr_accessor :config, :client
    
    # configure shover
    # +settings+ the settings for the created client as 
    # a string for a yaml file, or as a hash
    def configure settings
      if settings.kind_of? String
        self.config = YAML.load_file(settings)
      elsif settings.kind_of? Hash
        self.config = settings
      else
        raise "Unsupported configuration type"
      end
      
      self.client = Client.new config[:network], config[:key], config
    end
    
    # broadcast a message
    # +channel+ the channel to broadcast on
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def broadcast channel, event, message, &block
      client.broadcast channel, event, message, &block
    end
    
    # direct a message to a specific user
    # +uid+ the users id
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def direct uid, event, message, &block
      client.direct uid, event, message, &block
    end
    
    # authorize a user on a private channel
    # +uid+ the users id
    # +channel+ the channel to authorize them on
    def authorize uid, channel="*", &block
      client.authorize uid, channel, &block
    end

    # act as a stream client.  requires EM
    # +channel+ the channel to stream
    def stream channel, &block
      unless EM.reactor_running?
        raise "You can stream when running in an Eventmachine event loop.  EM.run { #code here }"
      end
      raise "Websocket client not implemented yet... soon"
    end
    
  end
end

require "shove/client"
require "shove/request"
require "shove/response"
