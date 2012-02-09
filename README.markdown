shove ruby client
=================

* The official ruby client for shove.io's HTTP and WebSocket API

Installation
------------

```bash
gem install shove
```

Grab your App ID and App Key from shove at [http://shove.io/customer/network/api_access#ruby][0]


Using the HTTP Client
---------------------

### Configure shove with your credentials

```ruby
require "shove"

Shove.configure do
  app_id "myappid"
  app_key "myappkey"
end
```

### Publish a message
Publish a message on the "notifcations" channel.  All clients subscribed
to the notifications channel will receive the message.

```ruby
Shove.channel("notifications").publish("Hello World!") do |response|
  # handle response
end
```

### Send a Direct Message
Publish a message to specific client.

```ruby
Shove.channel("direct:mark@google.com").publish("hello mark!") do |response|
  # handle response
end
```

### Control Access on Your App and Channels
Apps, as well as channels, may require access control
Some examples:

~~~~ ruby
# grant connection to dan@shove.io
Shove.grant_connect("dan@shove.io") do |response|
  # handle response
end

# grant subscription on the notifications channel to dan@shove.io
Shove.channel("notifications").grant_subscribe("dan@shove.io") do |response|
  # handle response
end

# grant subscription on all channels
Shove.channel("*").grant_subscribe("dan@shove.io") do |response|
  # handle response
end

# grant publishing on chat:client_22733 channel to dan@shove.io
Shove.channel("chat:client_22733").grant_publish("dan@shove.io") do |response|
  # handle response
end

# deny publishing on chat:client_22733 channel to dan@shove.io
Shove.channel("chat:client_22733").deny_publish("dan@shove.io") do |response|
  # handle response
end
~~~~

Using the WebSocket Client
--------------------------

Using the Command Line
----------------------

##CLI (Command line interface)
The shove gem comes with a command line tool for controlling the network.
View documentation @ [http://shove.io/documentation/cli][1]


[0]: http://shove.io/customer/network/api_access
[1]: http://shove.io/documentation/cli