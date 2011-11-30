module Shove
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
end