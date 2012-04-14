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
        @queue = []
        @forcedc = false
        @connected = false
      end

      def authorize app_key=nil
        send_data :opcode => AUTHORIZE, :data => (app_key || @config.app_key)
      end

      # Enable or disable debugging
      # +on+ true to enable debugging
      def debug on=true
        @debug = on
      end
      
      # Connect to the shove stream server
      def connect

        if @connected
          return
        end

        @socket = EM::WebSocketClient.new(url)

        @socket.onclose do
          @connected = false
          unless @forcedc
            reconnect
          end
        end

        @socket.onopen do
          @connected = true
          send_data :opcode => CONNECT, :data => @id
          until @queue.empty? do
            send_data @queue.shift
          end
        end

        @socket.onmessage do |m, binary|
          process(Yajl::Parser.parse(m))
        end

      end
      
      # Disconnect form the server
      def disconnect
        @forcedc = true
        @socket.unbind
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
          @url = "ws://#{@hosts.first}/#{@config.app_id}"
        end
        @url
      end
      
      def send_data data
        if @connected
          @socket.send_message(Yajl::Encoder.encode(data))
        else
          @queue << data
        end
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
        when AUTHORIZE_COMPLETE
          if @channels.key?(channel)
            @channels[channel].process(message)
          else
            emit "authorize_complete"
          end
        when AUTHORIZE_DENIED
          if @channels.key?(channel)
            @channels[channel].process(message)
          else
            emit "authorize_denied"
          end
        else
          puts "Unknown opcode"
        end

      end

      def host
        @hosts.first
      end
    
    end
  end
end
