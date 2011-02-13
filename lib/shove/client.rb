module Shove
  class Client

    # create an API client
    # +network+ the network id
    # +key+ the api access key
    # +opts+ hash with a few options, such as:
    # :secure true or false
    # :host leave as default unless you are given a private cluster
    def initialize network, key, opts={}
      @network = network
      @key = key
      @auth_header = { "api-key" => key }
      @secure = opts[:secure] || false
      @host = opts[:host] || "api.shove.io"
    end
    
    # broadcast a message
    # +channel+ the channel to broadcast on
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def broadcast channel, event, message, &block
      Request.new("#{uri}/#{@network}/broadcast/#{channel}/#{event}", @auth_header).post(message, &block)
    end
    
    # direct a message to a specific user
    # +uid+ the users id
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def direct uid, event, message, &block
      Request.new("#{uri}/#{@network}/direct/#{event}/#{uid}", @auth_header).post(message, &block)
    end
    
    # authorize a user on a private channel
    # +uid+ the users id
    # +channel+ the channel to authorize them on
    def authorize uid, channel="*", &block
      Request.new("#{uri}/#{@network}/authorize/#{channel}/#{uid}", @auth_header).post(&block)
    end
    
    protected
    
    def uri
      (@secure ? "https" : "http") + "://#{@host}"
    end
    
  end
end