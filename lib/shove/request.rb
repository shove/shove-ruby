module Shove
  class Request
    
    include EventMachine::HttpEncoding
    
    attr_accessor :url, :headers
    
    def initialize url, headers={}
      self.url = url
      self.headers = headers.merge({
        "api-key" => Shove.config[:key]
      })
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
    
    private

    # exec a HTTP request, and callback with
    # a response via block
    def exec method, params={}, &block
      
      # run async so we don't block if EM is running
      if EM.reactor_running?
        http = EventMachine::HttpRequest.new(url).send(method, { 
          :body => params,
          :head => headers 
        })
        
        # handle error
        http.errback {
          block.call(Response.new(http.response_header.status, http.response, true)) if block_given? 
        }
        
        # handle success
        http.callback {
          status = http.response_header.status
          block.call(Response.new(status, http.response, status >= 400)) if block_given? 
        }
      
      # fallback to standard lib for http  
      else
        uri = URI.parse(url)
        case method
        when :post, :put
          res = Net::HTTP.new(uri.host, uri.port).send(method, uri.path, normalize_body(params), headers)
        when :get, :delete
          res = Net::HTTP.new(uri.host, uri.port).send(method, uri.path, headers) 
        end
        block.call(Response.new(res.code, res.body, res.code.to_i >= 400)) if block_given? 
      end
    end
    
    def normalize_body(body)
      body.is_a?(Hash) ? form_encode_body(body) : body
    end
    
  end
end



