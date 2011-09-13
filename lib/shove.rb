$:.unshift File.dirname(__FILE__)

require "rubygems"
require "net/http"
require "em-http-request"
require "yajl"
require "yaml"

##
# Shove
# 
# See http://shove.io for an account and client documentation
# See https://github.com/shove/shover for gem documentation
# See https://github.com/shove/shove for client documentation
module Shove
  
  Version = "0.7"
  
  class << self
  
    attr_accessor :config, :client
    
    # configure shover
    # +settings+ the settings for the created client as 
    # a string for a yaml file, or as a hash
    def configure settings
      if settings.kind_of? String
        self.config = YAML.load_file(settings)
        self.config
      elsif settings.kind_of? Hash
        self.config = settings
      else
        raise "Unsupported configuration type"
      end

      self.client = Client.new(config)
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
    
    # fetch the available stream nodes
    # for this network.
    def hosts
      client.hosts
    end

    def version
      Version
    end
    
    # act as a stream client.  requires EM
    # +channel+ the channel to stream
    def stream channel, &block
      
      unless EM.reactor_running?
        puts "You can stream when running in an Eventmachine event loop.  EM.run { #code here }"
        exit
      end
      
      ## Fetch hosts
      hostnames = hosts
      
      if hostnames.empty?
        puts "Error fetching hosts for network #{config[:network]}"
        exit
      end
      
      uid  = ""
      http = EventMachine::HttpRequest.new("ws://#{hostnames.first}.shove.io/#{config[:network]}").get :timeout => 0
      
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
        
        block.call({
          :channel => parts[0],
          :event => parts[1],
          :to => parts[2],
          :from => parts[3],
          :data => parts[4]
        })
      }

    end
  end
end

require "shove/client"
require "shove/request"
require "shove/response"
