$:.unshift File.dirname(__FILE__)

require "rubygems"
require "net/http"
require "net/https"
require "em-http-request"
require "em-ws-client"
require "yajl"
require "yaml"
require "digest/sha1"

##
# Shove
# 
# See https://shove.io for an account and client documentation
# See https://github.com/shove/shove-ruby for gem documentation
# See https://github.com/shove/shove for js client documentation
module Shove
  
  Version = "1.0.8"

  # Exception class for all shove exception
  class ShoveException < Exception; end

end

require "shove/app"
require "shove/protocol"
require "shove/client/connection"
require "shove/client/channel"
require "shove/client/callback"
require "shove/http/request"
require "shove/http/response"
require "shove/http/channel_context"
require "shove/http/client_context"