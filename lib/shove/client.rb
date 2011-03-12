module Shove
  class Client

    # create an API client
    # +network+ the network id
    # +key+ the api access key
    # +opts+ hash with a few options, such as:
    # :secure true or false
    # :host leave as default unless you are given a private cluster
    def initialize opts={}
      @network = opts[:network]
      @cluster = opts[:cluster] || "a01"
      @secure = opts[:secure] || false
      @host = opts[:host] || "api.#{@cluster}.shove.io"
      @web_host = opts[:web_host] || "shove.io"
    end
    
    # broadcast a message
    # +channel+ the channel to broadcast on
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def broadcast channel, event, message, &block
      Request.new("#{uri}/broadcast/#{channel}/#{event}").post(message, &block)
    end
    
    # direct a message to a specific user
    # +uid+ the users id
    # +event+ the event to trigger
    # +message+ the message to send, UTF-8 encoded kthx
    def direct uid, event, message, &block
      Request.new("#{uri}/direct/#{event}/#{uid}").post(message, &block)
    end
    
    # authorize a user on a private channel
    # +uid+ the users id
    # +channel+ the channel to authorize them on
    def authorize uid, channel="*", &block
      Request.new("#{uri}/authorize/#{channel}/#{uid}").post(&block)
    end
    
    # validate current API settings
    def validate
      Request.new("#{uri}/validate").post do |response|
        return response
      end
    end
    
    # Channel methods
    
    # create a channel
    # +opts+ the hash containing channel options
    #   :restricted
    #   :name
    def create_channel opts, &block
      Request.new("#{channel_uri}").post({ :channel => opts }, &block)
    end
    
    # delete a channel
    # +name+ the name of the channel to delete
    def delete_channel name, &block
      Request.new("#{channel_uri}/#{name}").delete(&block)
    end
    
    # update the attributes of a channel
    # +name+ the name of the channel
    # +opts+ the options hash to update
    def update_channel name, opts, &block
      Request.new("#{channel_uri}/#{name}").put({ :channel => opts }, &block)
    end
    
    protected
    
    def uri
      (@secure ? "https" : "http") + "://#{@host}/#{@network}"
    end
    
    def channel_uri
      (@secure ? "https" : "http") + "://#{@web_host}/api/#{@network}/channels"
    end
    
  end
end