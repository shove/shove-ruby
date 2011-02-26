$:.unshift File.dirname(__FILE__)

require "rubygems"
require "net/http"
require "em-http-request"
require "yaml"

##
# Shove
# 
# See http://shove.io for an account
module Shove
  
  Version = 0.4
  
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
      
      # symbolize keys
      # self.config = {}
      #      tmp.each_pair do |k,v|
      #        self.config[k.to_sym] = v
      #      end
      
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
    
    # validate network settings
    # used for the CLI
    def validate
      client.validate
    end

    # act as a stream client.  requires EM
    # +channel+ the channel to stream
    def stream channel, &block
      
      unless EM.reactor_running?
        raise "You can stream when running in an Eventmachine event loop.  EM.run { #code here }"
      end
      
      uid = ""
      
      http = EventMachine::HttpRequest.new("ws://ws.shove.io/#{config[:network]}").get :timeout => 0
      
      http.errback {
        block.call("Connection Error")
      }
      
      http.callback {
        block.call("Connected")
        http.send("#{channel}!$subscribe!!!")
      }

      http.stream { |msg|
        
        parts = msg.split "!"
        
        case parts[1]
        when "$identity"
          uid = parts.last
        when "$unauthorized"
          Shove.authorize uid, channel
        end
        
        block.call(msg)
      }

    end
  end
end

require "shove/client"
require "shove/request"
require "shove/response"
