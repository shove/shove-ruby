module Shove
  class Client

    ERROR = 0x00

    # Connection
    CONNECT = 0x01
    CONNECT_GRANTED = 0x02
    CONNECT_DENIED = 0x03
    DISCONNECT = 0x04
    DISCONNECT_COMPLETE = 0x06

    # Subscribe Ops
    SUBSCRIBE = 0x10 
    SUBSCRIBE_GRANTED = 0x11
    SUBSCRIBE_DENIED = 0x12
    UNSUBSCRIBE = 0x13
    UNSUBSCRIBE_COMPLETE = 0x14

    # Publish Ops
    PUBLISH = 0x20 
    PUBLISH_DENIED = 0x21
    PUBLISH_GRANTED = 0x22

    # Authorize Ops
    GRANT_PUBLISH = 0x30 
    GRANT_SUBSCRIBE = 0x31
    GRANT_CONNECT = 0x32
    GRANT_CONTROL = 0x33

    # Deny Ops
    DENY_PUBLISH = 0x40 
    DENY_SUBSCRIBE = 0x41
    DENY_CONNECT = 0x42
    DENY_CONTROL = 0x43

    # Log Ops
    LOG = 0x50 
    LOG_STARTED = 0x51
    LOG_DENIED = 0x52

    # Self authorize
    AUTHORIZE = 0x60
    AUTHORIZE_COMPLETE = 0x61
    AUTHORIZE_DENIED = 0x62

    # Presence Ops
    PRESENCE_SUBSCRIBED = 0x70
    PRESENCE_UNSUBSCRIBED = 0x71
    PRESENCE_LIST = 0x72

    class Channel
      # Create a new channel
      # +name+ The name of the channel
      def initialize name
        @name = name
        @callbacks = {}
      end

      # Bind a block to an event
      # +event+ the event name
      # +block+ the callback
      def on event, &block
        unless @callbacks.has_key?(event)
          @callbacks[event] = []
        end
        @callbacks[event] << block
      end
      
      # Process a message for the channel
      # +message+ the message in question
      def process message
        process_event("*", message)
        process_event(message["event"], message)
      end
      
      # Check whether or not an event exists
      # +event+ the event name
      def event? event
        @callbacks.has_key?(event)
      end
      
      private
      
      def process_event event, message
        return unless event?(event)
        @callbacks[event].each do |cb|
          cb.call(message)
        end
      end
    end

    attr_accessor :id

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
    end
    
    # Connect to the shove stream server
    def connect
      if @hosts.empty?
        raise "Error fetching hosts for app #{@app_id}"
      end
      
      @socket = EM::WebSocketClient.new("ws://#{host}.shove.io:9000/#{@config.app_id}")
      @socket.onopen do |m|
        on_ws_connect
      end
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
    def on event, &block
      unless @events.has_key?(event)
        @events[event] = []
      end
      @events[event] << block
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

    def emit event, *args
      if @events.has_key?(event)
        @events[event].each do |block|
          block.call(args)
        end
      end
    end

    def on_ws_connect
      send({
        :opcode => CONNECT,
        :data => @id
      })
    end

    def send data
      @socket.send_data(Yajl::Encoder.encode(data))
    end

    def process message
      case message["opcode"]
      when CONNECT_GRANTED
        @id = message["data"]
        emit "connect", @id
      when CONNECT_DENIED
        emit "connect_denied"
      else
        puts "Not supported, bro"
      end

      # if @channels.has_key?(message["channel"])
      #   @channels[message["channel"]].process(message)
      # end
    end

    def host
      @hosts.first
    end
    
  end
end
