module Shove
  class Subscriber
  
    def initialize config, hosts
      @app = config[:app]
      @parser = Yajl::Parser.new(:symbolize_keys => true)
      @hosts = hosts
      @channels = {}
    end
    
    # Connect to the shove stream server
    def connect
      if @hosts.empty?
        raise "Error fetching hosts for app #{@app}"
      end
      
      @socket = EM::WebSocketClient.new("ws://#{host}.shove.io/#{@app}")
      @socket.onmessage do |m|
        process Yajl::Parser.parse(m)
      end
    end
    
    # Disconnect form the server
    def disconnect
      @socket.disconnect
    end
  
    def on channel, event, &block
      
      unless @channels.has_key?(channel)
        @channels[channel] = Channel.new(channel)
      end
      
      chan = @channels[channel]
      chan.on(event, &block)
      
      @socket.send_data(Yajl::Encoder.encode({
        :event => "$subscribe",
        :channel => channel
      }))
      
    end
    
    def process message
      if @channels.has_key?(message["channel"])
        @channels[message["channel"]].process(message)
      end
    end
    
    private
    
    def host
      @hosts.first
    end
  
  end
end