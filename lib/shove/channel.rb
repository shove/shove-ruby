module Shove
  class Channel
  
    def initialize name
      @name = name
      @callbacks = {}
    end

    def on event, &block
      unless @callbacks.has_key?(event)
        @callbacks[event] = []
      end
      @callbacks[event] << block
    end
    
    def process message
      process_event("*", message)
      process_event(message["event"], message)
    end
    
    def event? event
      @callbacks.has_key?(event)
    end
    
    def process_event event, message
      return unless event?(event)
      @callbacks[event].each do |cb|
        cb.call(message)
      end
    end
  
  end
end