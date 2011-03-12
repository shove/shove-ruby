#shover

* The official ruby gem for shove.io's REST API

##Install Step 1

	gem install shove

##Install Step 2
  Grab your network id and API key from shove at [http://shove.io/customer/network/api_access#ruby][0]
  
##Install Step 3
  Configure shover with your credentials
  
    require "shove"
  
    Shove.configure(
      :network => "network",
      :key => "apikey",
      :cluster => "cluster"
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
    
##Stream all data from a channel

    # stream all data on channel "default"
    Shove.stream("default") do |msg|
      
      # msg has several properties
      puts msg[:channel]
      puts msg[:event]
      puts msg[:to] # this will either be empty or self
      puts msg[:from] # message sender
      puts msg[:data] # the payload

    end
    
##Channel Management
Creating channels is a privileged operation.  You can do it from the shove.io management console, or via the management API. 
In the case of the ruby gem, you can manage it straight from ruby.

    # Create a channel
    options = {
      :name => "funchannel", #this is the only required field
      :restricted => false, #require authorization for subscription
      :broadcastable => true, #allow clients to broadcast to other clients
      :presence => true #when users subscribe/unsubscribe all other subscribers are notified
    }
    Shove.create_channel(options) do |response|
      if response.error?
        puts "boooo"
        puts response.message
      end
    end
    
    # Update a channel
    Shove.update_channel("funchannel", :presence => false) do |response|
      # ...
    end
    
    # Delete channel
    # this will unsubscribe all subscribers from this channel
    # nearly immediately, so make sure you want to do that.
    Shove.delete_channel("funchannel") do |response|
      # ...
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