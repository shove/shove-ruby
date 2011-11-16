module Shove
  class Control

    # create an API client
    # +app_id+ the app id
    # +app_key+ the api access key
    # +opts+ hash with a few options, such as:
    # :secure true or false
    # :host leave as default unless you have a dedicated cluster
    def initialize opts={}
      @app_id = opts[:app_id]
      @app_key = opts[:app_key]
      
      unless @app_id && @app_key
        raise ShoveExcepton.new("App ID and App Key are required for control")
      end
      
      @secure = opts[:secure] || false
      @host = opts[:host] || "api.shove.io"
      @port = opts[:port] || (@secure ? 443 : 80)
    end
    
    # authorize a user on a private channel
    # +uid+ the users id
    # +channel+ the channel to authorize them on
    def authorize uid, channel="*", &block
      Request.new("#{uri}/authorize/#{channel}/#{uid}", @app_key).post(&block)
    end
    
    # validate current API settings
    def validate
      Request.new("#{uri}/validate", @app_key).post do |response|
        return !response.error?
      end
    end
    
    # fetch a list of node names for streaming websockets and comet
    def hosts
      Request.new("#{uri}/hosts").exec_sync(:get).parse
    end
        
    protected
    
    def uri
      (@secure ? "https" : "http") + "://#{@host}:#{@port}/#{@app_id}"
    end
    
  end
end
