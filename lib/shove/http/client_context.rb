module Shove
  module Http
    class ClientContext

      attr_accessor :app, :id

      def initialize app, id
        @app = app
        @id = id
      end

      # publish a message directly to the client
      # +message+ the message to publish
      # +block+ called on response
      def publish message, &block
        @app.request("publish?channel=direct:#{@id}").post(message.to_s, &block)
      end

      # grant connection to client
      # use this in cases where the app disallows any activity
      # on newly established clients.
      # +block+ called on response
      def grant_connect &block
        @app.request("grant_connect?client=#{@id}").post(&block)
      end

      # grant control to client
      # turns the client into a full blown control client, allowing
      # them to subscribe and publish to all channels, as well
      # as grant and deny actions to other clients
      # +block+ called on response
      def grant_control &block
        @app.request("grant_control?client=#{@id}").post(&block)
      end

      # grant connection to client
      # use this to kick a client
      # +block+ called on response
      def deny_connect &block
        @app.request("deny_connect?client=#{@id}").post(&block)
      end

      # grant connection to client
      # use this to revoke power.  Clients will never have
      # control by default, so this would always be called
      # after calling grant_control
      # +block+ called on response
      def deny_control &block
        @app.request("deny_control?client=#{@id}").post(&block)
      end

      # grant subscription to client
      # +channel+ the channel to grant subscription on
      # +block+ called on response
      def grant_subscribe channel, &block
        @app.request("grant_subscribe?channel=#{channel}&client=#{@id}").post(&block)
      end

      # grant publishing to client
      # +channel+ the channel to grant publishing on
      # +block+ called on response
      def grant_publish channel, &block
        @app.request("grant_publish?channel=#{channel}&client=#{@id}").post(&block)
      end

      # deny subscription to client
      # +channel+ the channel to deny subscription on
      # +block+ called on response
      def deny_subscribe channel, &block
        @app.request("deny_subscribe?channel=#{channel}&client=#{@id}").post(&block)
      end

      # deny publishing to client
      # +channel+ the channel to deny publishing on
      # +block+ called on response
      def deny_publish channel, &block
        @app.request("deny_publish?channel=#{channel}&client=#{@id}").post(&block)
      end

    end
  end
end