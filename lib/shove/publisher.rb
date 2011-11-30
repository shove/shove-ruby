module Shove
  class Publisher

    # Create a Publisher
    # +app_id+ the app id
    # +app_key+ the api access key
    # +opts+ hash with a few options, such as:
    # :secure true or false
    # :host leave as default unless you have a dedicated cluster
    # :port for the port of the host
    def initialize opts={}
      @app_id = opts[:app_id]
      @app_key = opts[:app_key]
      
      unless @app_id && @app_key
        raise ShoveExcepton.new("App ID and App Key are required for publishing")
      end
      
      @secure = opts[:secure] || false
      @host = opts[:host] || "api.shove.io"
      @port = opts[:port] || (@secure ? 443 : 80)
    end
    
    # publish a message
    # +channel+ the channel to broadcast on
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def publish channel, event, message, &block
      Request.new("#{uri}/publish/#{channel}/#{event}", @app_key).post(message, &block)
    end
    
    # direct a message to a specific user
    # +uid+ the users id
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def direct uid, event, message, &block
      Request.new("#{uri}/direct/#{event}/#{uid}", @app_key).post(message, &block)
    end
        
    protected
    
    def uri
      (@secure ? "https" : "http") + "://#{@host}:#{@port}/#{@app_id}"
    end
    
  end
end
