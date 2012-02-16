module Shove
  module Client
    class Connection

      include Protocol

      attr_accessor :id, :socket, :url

      # Create a Publisher
      # +app+ the app
      def initialize app, id
        @id = id
        @app = app
        @parser = Yajl::Parser.new(:symbolize_keys => true)
        @config = app.config
        @hosts = app.hosts
        @channels = {}
        @events = {}

        @forcedc = false
        @connected = false
      end
      
      # Connect to the shove stream server
      def connect

        if @connected
          return
        end

        @socket = EM::WebSocketClient.new(url)
        @socket.onopen do
          @connected = true
          on_ws_connect
        end
        
        @socket.onmessage do |m|
          process Yajl::Parser.parse(m)
        end

        @socket.onclose do
          @connected = false
          unless @forcedc
            reconnect
          end
        end
      end
      
      # Disconnect form the server
      def disconnect
        @forcedc = true
        @socket.disconnect
      end

      # Bind to events for a given channel.
      # +channel+ the channel name to subscribe to
      # +event+ the event name to bind to
      # +block+ the block which is called when a message is received
      def on event, &block
        unless @events.key?(event)
          @events[event] = []
        end
        @events[event] << block
      end

      # Fetch a channel
      # +name+ the name of the channel
      def channel name
        unless @channels.key?(name)
          @channels[name] = Channel.new(name, self)
          if name != "direct"
            @channels[name].subscribe
          end
        end
        @channels[name]
      end

      def url
        if @config.ws_url
          @url = "#{@config.ws_url}/#{@config.app_id}"
        else
          if @hosts.empty?
            raise "Error fetching hosts for app #{@app_id}"
          end
          @url = "ws://#{@hosts.first}.shove.io/#{@config.app_id}"
        end
        @url
      end
      
      def send_data data
        @socket.send_data(Yajl::Encoder.encode(data))
      end

      protected

      def reconnect
        @reconnecting = true
      end

      def emit event, *args
        if @events.key?(event)
          @events[event].each do |block|
            block.call(*args)
          end
        end
      end

      def on_ws_connect
        send_data :opcode => CONNECT, :data => @id
      end

      def process message

        op = message["opcode"]
        data = message["data"]
        channel = message["channel"]

        case op
        when CONNECT_GRANTED
          @id = data
          emit "connect", @id
        when CONNECT_DENIED
          @id = data
          emit "connect_denied", @id
        when DISCONNECT
          @closing = true
          emit "disconnect", data
        when ERROR
          emit "error", data
        when PUBLISH
          channel = channel =~ /direct/ ? "direct" : channel
          if @channels.key?(channel)
            @channels[channel].process(message)
          end
        when SUBSCRIBE_GRANTED,
             SUBSCRIBE_DENIED,
             PUBLISH_GRANTED,
             PUBLISH_DENIED,
             UNSUBSCRIBE_COMPLETE
          if @channels.key?(channel)
            @channels[channel].process(message)
          end
        when DISCONNECT_COMPLETE
          @closing = true
          emit "disconnecting"
        else
          #TODO: logger
          puts "Unknown opcode"
        end

      end

      def host
        @hosts.first
      end
    
    end
  end
end
