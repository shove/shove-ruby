#shover

* The official ruby gem for shove.io's HTTP API

##Install Step 1

	gem install shove

##Install Step 2
  Grab your network id and API key from shove at [http://shove.io/customer/network/api_access#ruby][0]
  
##Install Step 3
  Configure shover with your credentials
  
    require "shove"
  
    Shove.configure(
      :network => "network",
      :key => "apikey"
    )

##Broadcasting

    # broadcast the "hello" event on the "default" channel with
    # Hello World! as the data
    Shove.broadcast("default", "hello", "Hello World!") do |response|
      puts response.error?
      puts response.status
      puts response.message
    end
  
##Send direct messages

    Shove.direct(userid, "hello", "Hello World!") do |response|
      # handle response
    end

##Subscription Authorization

    # authorize user with id userid on channel "default"
    Shove.authorize(userid, "default") do |response|
      # handle response
    end
    
##Channel Streaming

    # stream all data on channel "default"
    Shove.stream("default") do |msg|
      
      # msg has several properties
      puts msg[:channel]
      puts msg[:event]
      puts msg[:to] # this will either be empty or self
      puts msg[:from] # message sender
      puts msg[:data] # the payload

    end
  
##Block and Non-blocking
  shover does both.  If the shover code happens to run inside of an EM.run block, the HTTP calls
  will leverage em-http-request.  Otherwise, the requests fallback to net/http requests.  We recommend
  using EM if possible.
  
##CLI (Command line interface)
  The shove gem comes with a command line tool for controlling the network.
  View documentation @ [http://shove.io/documentation/cli][1]


[0]: http://shove.io/customer/network/api_access
[1]: http://shove.io/documentation/cli