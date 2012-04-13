module Shove
  module Client
    class Channel

      include Protocol

      attr_accessor :name

      # Create a new channel
      # +name+ The name of the channel
      def initialize name, conn
        @conn = conn
        @name = name.to_s
        @callbacks = {}
        @subscribe_sent = false
      end

      # Bind a block to an event
      # +event+ the event name
      # +block+ the callback
      def on event, &block
        unless @callbacks.has_key?(event)
          @callbacks[event] = []
        end
        result = Callback.new(@callbacks[event], block)
        @callbacks[event] << result

        if @name != "direct" && !@subscribe_sent
          subscribe
        end

        result
      end
      
      # Process a message for the channel
      # +message+ the message in question
      def process message
        op = message["opcode"]
        data = message["data"]

        case op
        when PUBLISH
          emit("message", data)
        when SUBSCRIBE_GRANTED
          emit("subscribe")
        when SUBSCRIBE_DENIED
          emit("subscribe_denied")
        when PUBLISH_DENIED
          emit("publish_denied")
        when PUBLISH_GRANTED
          emit("publish_granted")
        when UNSUBSCRIBE_COMPLETE
          emit("unsubscribe")
          @callbacks.clear
        when AUTHORIZE_DENIED
          emit("authorize_denied")
        when AUTHORIZE_COMPLETE
          emit("authorize_complete")
        end

      end

      # publish a message on the channel
      # +msg+ the message to publish.  It must implement to_s
      def publish msg
        @conn.send_data :opcode => PUBLISH, :channel => @name, :data => msg.to_s
      end

      # subscribe to the channel, by sending to the remote
      def subscribe
        @conn.send_data :opcode => SUBSCRIBE, :channel => @name
        @subscribe_sent = true
      end

      # unsubscribe from the channel
      def unsubscribe
        @conn.send_data :opcode => UNSUBSCRIBE, :channel => @name
      end

      # authorize pub/sub on this channel
      def authorize channel_key
        @conn.send_data :opcode => AUTHORIZE, :channel => @name, :data => channel_key.to_s
      end

      private

      def emit event, *args
        if @callbacks.key?(event)
          @callbacks[event].each do |cb|
            cb.call(*args)
          end
        end
      end

    end
  end
end
