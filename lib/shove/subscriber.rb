module Shove
  class Subscriber
  
    # Create a Publisher
    # +app_id+ the app id
    # +hosts+ the lists of hosts (not FQDN)
    def initialize config, hosts
      @app_id = config[:app_id]
      @parser = Yajl::Parser.new(:symbolize_keys => true)
      @hosts = hosts
      @channels = {}
    end
    
    # Connect to the shove stream server
    def connect
      if @hosts.empty?
        raise "Error fetching hosts for app #{@app_id}"
      end
      
      @socket = EM::WebSocketClient.new("ws://#{host}.shove.io/#{@app_id}")
      @socket.onmessage do |m|
        process Yajl::Parser.parse(m)
      end
    end
    
    # Disconnect form the server
    def disconnect
      @socket.disconnect
    end
  
    # Bind to events for a given channel.
    # +channel+ the channel name to subscribe to
    # +event+ the event name to bind to
    # +block+ the block which is called when a message is received
    def on channel, event, &block
      
      unless @channels.has_key?(channel)
        @channels[channel] = Channel.new(channel)
      end
      
      chan = @channels[channel]
      chan.on(event, &block)
      
      @socket.send_data(Yajl::Encoder.encode({
        :data => channel,
        :event => "subscribe",
        :channel => "$"
      }))
      
    end

    # Debug the app and receive
    # all pertinent information and messages
    # +block+ the block to call when any event occurs
    def debug &block
      @socket.send_data(Yajl::Encoder.encode({
        :event => "debug",
        :channel => "$"
      }))

      @socket.onmessage do |m|
        block.call Yajl::Parser.parse(m)
      end
    end
    
    private

    def process message
      if @channels.has_key?(message["channel"])
        @channels[message["channel"]].process(message)
      end
    end

    def host
      @hosts.first
    end
  
  end
end