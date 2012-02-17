
module Shove
  module Client
    # Represents a callback that can be canceled
    class Callback
      
      def initialize group, block
        @group = group
        @block = block
      end

      def call *args
        @block.call(*args)
      end

      def cancel
        @group.delete self
        @block = nil
      end

    end
  end
end
  