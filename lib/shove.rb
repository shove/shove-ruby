$:.unshift File.dirname(__FILE__)

require "rubygems"
require "yaml"

##
# Shove
# 
# See http://shoveapp.com/documentation for an account
# 
# = Example
#   
#   Shove.configure :network => "mynetwork", :key => "myapikey"
#   Shove.shove "mychannel", "myevent", "my payload, json, xml, string, etc"
module Shove
  
  Version = 0.1
  
  class << self
  
    attr_accessor :config
    
    def configure settings
      if settings.kind_of? String
        self.config = YAML.load_file(settings)
      elsif settings.kind_of? Hash
        self.config = settings
      else
        raise "Unsupported configuration type"
      end
    end
    
    def shove channel, event, message
    end
    
    def direct id, message
    end
  
  end
end

require "shove/request"

