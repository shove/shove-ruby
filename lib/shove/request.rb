module Shove
  class Request
    
    include EventMachine::HttpEncoding
    
    attr_accessor :url, :headers
    
    def initialize url
      self.url = url
    end
    
    # HTTP Delete request
    def delete &block
      exec :delete, &block
    end
  
    # HTTP Post request for new content
    def post params={}, &block
      exec :post, params, &block
    end
    
    # HTTP Put request for updates
    def put params={}, &block
      exec :put, params, &block
    end
    
    # HTTP Get request
    def get &block
      exec :get, &block
    end
    
    def exec_sync method, params={}, &block
      uri = URI.parse(url)
      
      req = {
        :post => Net::HTTP::Post,
        :put => Net::HTTP::Put,
        :get => Net::HTTP::Get,
        :delete => Net::HTTP::Delete
      }[method].new(uri.path)
      
      req.basic_auth "", Shove.config[:key]

      res = Net::HTTP.start(uri.host, uri.port) { |http|
        http.request(req, normalize_body(params))
      }

      result = Response.new(res.code, res.body, res.code.to_i >= 400)
      if block_given?
        block.call(result)
      end
      
      result
    end
    
    def exec_async method, params={}, &block
      http = EventMachine::HttpRequest.new(url).send(method, { 
        :body => params,
        :head => {
          :authorization => ["", Shove.config[:key]]
        } 
      })
      
      # handle error
      http.errback {
        block.call(Response.new(http.response_header.status, http.response, true)) 
      }
      
      # handle success
      http.callback {
        status = http.response_header.status
        block.call(Response.new(status, http.response, status >= 400))
      }
    end
    
    # exec a HTTP request, and callback with
    # a response via block
    def exec method, params={}, &block
      
      # run async so we don't block if EM is running
      if EM.reactor_running?
        exec_async(method, params, &block)
      # fallback to standard lib for http  
      else
        exec_sync(method, params, &block)
      end
    end
    
    def normalize_body(body)
      body.is_a?(Hash) ? form_encode_body(body) : body
    end
    
  end
end



