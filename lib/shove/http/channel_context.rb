module Shove
  module Http
    class ChannelContext

      attr_accessor :app, :channel

      def initialize app, channel
        @app = app
        @channel = channel
      end

      # publish a message on the channel
      # +message+ the message to publish
      # +block+ called on response
      def publish message, &block
        if @channel == "*"
          raise ShoveException.new("Cannot publish to *")
        elsif message.size > 8096
          raise ShoveException.new("Max message size is 8,096 bytes")
        end
        @app.request("publish?channel=#{@channel}").post(message, &block)
      end

      # grant subscription on the channel
      # +client+ the client to grant
      # +block+ called on response
      def grant_subscribe client, &block
        control_request("grant_subscribe", client, &block)
      end

      # grant publishing on the current channel
      # +client+ the client to grant
      # +block+ called on response
      def grant_publish client, &block
        control_request("grant_publish", client, &block)
      end

      # deny subscription on the channel
      # +client+ the client to deny
      # +block+ called on response
      def deny_subscribe client, &block
        control_request("deny_subscribe", client, &block)
      end

      # deny publishing on the channel
      # +client+ the client to deny
      # +block+ called on response
      def deny_publish client, &block
        control_request("deny_publish", client, &block)
      end

      private

      def control_request action, client, &block
        @app.request("#{action}?channel=#{@channel}&client=#{client}").post(&block)
      end

    end
  end
end