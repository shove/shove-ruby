module Shove
  class Response
    
    attr_accessor :status, :message, :error
    
    def initialize status, message, error=false
      self.status = status.to_i
      self.message = message
      self.error = error
    end
    
    def error?
      error
    end

  end
end
