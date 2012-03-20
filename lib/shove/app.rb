module Shove
  class App

    attr_accessor :config

    # create an API client
    # +config+ optional Confstruct
    # +&block+ config block
    # Example:
    # Shove::App.new do
    #   app_id "myappid"
    #   app_key "myappkey"
    # end
    def initialize config=Confstruct::Configuration.new, &block
      @config = config
      configure(&block)
    end

    def configure params={}, &block

      @config.configure do
        api_url Shove.config.api_url || "https://api.shove.io"
      end

      if params
        @config.configure params
      end
      
      if block
        @config.configure(&block)
      end

      unless @config.app_id
        raise ShoveException.new("App ID required")
      end
    end

    # is the app valid?
    # do the app_id and app_key work with the remote
    def valid?
      !request("validate").exec_sync(:get).error?
    end
    
    # get a list of websocket hosts
    def hosts
      request("hosts").exec_sync(:get).parse
    end

    # create a channel context for acting on a channel
    # +name+ the name of the channel
    def channel name
      Http::ChannelContext.new(self, name)
    end

    # create a cleint context for acting on a client
    # +id+ the id of the client
    def client id
      Http::ClientContext.new(self, id)
    end

    # the base URL based on the settings
    def url
      "#{@config.api_url}/apps/#{@config.app_id}"
    end

    # Create a default request object with the base URL
    # +path+ extra path info
    def request path
      Http::Request.new("#{url}/#{path}", @config)
    end

    ####

    # Connect to shove as a client in the current process
    # +id+ optional shove id to supply
    def connect id=nil
      client = Client::Connection.new(self, id)
      client.connect
      client
    end

  end
end
