#shover

* The official ruby gem for shove.io's REST API

##Install Step 1

	gem install shove

##Install Step 2
  Grab your network id and API key from shove at http://shove.io/customer/network/api_access
  
##Install Step 3
  Configure shover with your credentials
  
    require "shove"
  
    Shove.configure(
      :network => "network",
      :key => "apikey"
    )

##Broadcast messages

    # broadcast the "hello" event on the "default" channel with
    # Hello World! as the data
    Shove.broadcast("default", "hello", "Hello World!") do |response|
      puts response.error?
      puts response.status
      puts response.message
    end
  
##Direct messages

    Shove.direct(userid, "hello", "Hello World!") do |response|
      # handle response
    end

##Authorize a user

    # authorize user with id userid on channel "default"
    Shove.authorize(userid, "default") do |response|
      # handle response
    end
  
##Block and Non-blocking
  shover does both.  If the shover code happens to run inside of an EM.run block, the HTTP calls
  will leverage em-http-request.  Otherwise, the requests fallback to net/http requests.  We recommend
  using EM if possible.
  
