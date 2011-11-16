$:.unshift File.dirname(__FILE__)

require "rubygems"
require "net/http"
require "em-http-request"
require "em-ws-client"
require "yajl"
require "yaml"

##
# Shove
# 
# See http://shove.io for an account and client documentation
# See https://github.com/shove/shover for gem documentation
# See https://github.com/shove/shove for client documentation
module Shove
  
  Version = "1.0.0"
  
  class ShoveException < Exception; end
  
  class << self
  
    attr_accessor :config
    
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
    end
    
    # build a Publisher object
    def publisher
      Publisher.new(config)
    end
    
    # build a Publisher object
    def control
      Control.new(config)
    end
    
    # build a subscriber object
    def subscriber
      Subscriber.new(config, hosts)
    end
    
    # publish a message
    # +channel+ the channel to broadcast on
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def publish channel, event, message, &block
      publisher.publish channel, event, message, &block
    end
    
    # direct a message to a specific user
    # +uid+ the users id
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def direct uid, event, message, &block
      publisher.direct uid, event, message, &block
    end
    
    # authorize a user on a private channel
    # +uid+ the users id
    # +channel+ the channel to authorize them on
    def authorize uid, channel="*", &block
      control.authorize uid, channel, &block
    end
    
    # validate network settings
    # used for the CLI
    def validate
      control.validate
    end
    
    # fetch the available stream nodes
    # for this network.
    def hosts
      control.hosts
    end

    def version
      Version
    end
    
    # act as a stream client.  requires EM
    # +channel+ the channel to stream
    def stream channel, event, &block
      
      unless EM.reactor_running?
        puts "You can stream when running in an Eventmachine event loop.  EM.run { #code here }"
        exit
      end
      
      sub = subscriber
      sub.connect
      sub.channel(channel).on(channel, "*", block)

    end
  end
end

require "shove/channel"
require "shove/publisher"
require "shove/control"
require "shove/subscriber"
require "shove/request"
require "shove/response"
