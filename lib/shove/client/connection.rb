module Shove
  module Client
    class Connection

      include Protocol

      attr_accessor :id, :socket, :url

      # Create a Publisher
      # +app+ the app
      def initialize app
        @app = app
        @parser = Yajl::Parser.new(:symbolize_keys => true)
        @channels = {}
        @events = {}
        @queue = []
        @forcedc = false
        @connected = false
      end

      # helper to auth on all channels if app_key is supplied
      def auth!
        if @app.app_key
          channel("*").auth @app.channel_key("*")
        end
      end


      # Enable or disable debugging
      # +on+ true to enable debugging
      def debug on=true
        @debug = on
      end
      
      # Connect to the shove stream server
      def connect connect_key=nil
        @connect_key = connect_key

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
          send_data :opcode => CONNECT, :data => (connect_key || @app.connect_key)
          auth!
          until @queue.empty? do
            send_data @queue.shift
          end
        end

        @socket.onmessage do |m, binary|
          if @debug
            puts "DEBUG RECV #{m}"
          end

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
        if @app.ws_url
          @url = "#{@app.ws_url}/#{@app.app_id}"
        else
          if @app.hosts.empty?
            raise "Error fetching hosts for app #{@app_id}"
          end
          @url = "ws://#{@app.hosts.sample}/#{@app.app_id}"
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
        unless @forcedc
          @reconnecting = true
          EM.add_timer(1) do
            connect @connect_key
          end
        end
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
        @app.hosts.sample
      end
    
    end
  end
end
