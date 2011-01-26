
module Shove
  class Request
    
    attr_accessor :url, :headers
    
    def initialize url, headers={}
      self.url = url
      self.headers = headers
    end
    
    def post params={}, &block
      if EM.reactor_running?
        http = EventMachine::HttpRequest.new(url).post(:body => params, :head => headers)
        if block
          http.errback { 
            block.call(Response.new(http.response_header.status, http.response, true))
          }
          http.callback {
            block.call(Response.new(http.response_header.status, http.response, false))
          }
        end
      end
    end

  end
end



