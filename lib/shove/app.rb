module Shove
  class App

    attr_accessor :app_key, :app_id, :api_url, :ws_url

    # create an API client
    # +config+ optional Confstruct
    # +&block+ config block
    # Example:
    # Shove::App.new(
    #   app_id: "myappid"
    #   app_key: "myappkey"
    # )
    def initialize config={}
      @config  = config
      @app_id  = config[:app_id]
      @app_key = config[:app_key]
      @api_url = config[:api_url] || "https://api.shove.io"
      @ws_url  = config[:ws_url]

      raise ShoveException.new("App ID required") unless @app_id
    end

    # is the app valid?
    # do the app_id and app_key work with the remote
    def valid?
      !request("validate").exec_sync(:get).error?
    end
    
    # get a list of websocket hosts
    def hosts
      @hosts ||= request("hosts").exec_sync(:get).parse
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
      "#{@api_url}/apps/#{@app_id}"
    end

    # Create a default request object with the base URL
    # +path+ extra path info
    def request path
      Http::Request.new("#{url}/#{path}", self)
    end

    # Generate a channel key for a client to self authorize
    # publish and subscribe actions.
    # +channel+ the name of the channel
    def channel_key channel
      Digest::SHA1.hexdigest "#{@app_key}-#{channel}!"
    end

    # Generate a channel key for a client to self authorize
    # publish and subscribe actions.
    # +channel+ the name of the channel
    def publish_key channel
      channel_key channel
    end

    # Generate a channel key for a client to self authorize
    # subscribe actions.
    # +channel+ the name of the channel
    def subscribe_key channel
      Digest::SHA1.hexdigest "#{@app_key}-#{channel}"
    end

    # Generate a connect key for a client to self authorize
    # publish and subscribe actions.
    # +channel+ the name of the channel
    def connect_key
      Digest::SHA1.hexdigest "#{@app_key}-connect"
    end

    ####

    # Connect to shove as a client in the current process
    # +id+ optional shove id to supply
    def connect connect_key=nil
      client = Client::Connection.new(self)
      client.connect connect_key
      client
    end

  end
end
