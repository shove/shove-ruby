module Shove
  class Response
    
    attr_accessor :status, :message, :error
    
    def initialize status, message, error=false
      self.status = status.to_i
      self.message = message
      self.error = error
    end
    
    # was there an error with the request?
    def error?
      error
    end
    
    # generate a hash from a json response
    def to_hash
      @hash ||= Yajl::Parser.new(:symbolize_keys => true).parse(message)
    end

  end
end
