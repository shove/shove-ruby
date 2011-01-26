$:.unshift File.dirname(__FILE__)

require "rubygems"
require "eventmachine"
require "em-http"
require "yaml"
require "json"

##
# Shove
# 
# See http://shoveapp.com for an account
# 
# = Example
#   
#   Shove.configure :network => "mynetwork", :key => "myapikey"
#   Shove.broadcast "mychannel", "myevent", "my payload, json, xml, string, etc"
module Shove
  
  Version = 0.1
  
  class << self
  
    attr_accessor :config, :client
    
    ##
    # configure
    #
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
    
    ##
    # broadcast
    #
    def broadcast channel, event, message, &block
      client.broadcast channel, event, message, &block
    end
    
    ##
    # direct
    #
    def direct uid, event, message, &block
      client.direct uid, event, message, &block
    end
    
    ##
    # authorize
    #
    def authorize uid, channel="*", &block
      client.authorize uid, channel, &block
    end

    ##
    # stream
    #
    def stream
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
