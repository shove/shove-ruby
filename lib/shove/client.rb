
module Shove
  class Client

    def initialize network, key, opts={}
      @network = network
      @key = key
      @auth_header = { "api-key" => key }
      @secure = opts[:secure] || false
    end
    
    def broadcast channel, event, message, &block
      Request.new("#{uri}/broadcast/#{@network}/#{channel}/#{event}", @auth_header).post(message, &block)
    end
    
    def direct uid, event, message, &block
      Request.new("#{uri}/direct/#{@network}/#{event}/#{uid}", @auth_header).post(message, &block)
    end
    
    def authorize uid, channel="*", &block
      Request.new("#{uri}/authorize/#{uid}/#{channel}", @auth_header).post(&block)
    end
    
    protected
    
    def uri
      (@secure ? "https" : "http") + "://api.dev.shoveapp.com"
    end
    
  end
end