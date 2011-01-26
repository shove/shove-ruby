module Shove
  class Response
    
    attr_accessor :status, :message, :error
    
    def initialize status, message, error=false
      self.status = status
      self.message = message
      self.error = error
    end

  end
end
