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

### Create a WebSocket client

```ruby
# create a connect
client = Shove.app.connect

# create a client with a given id
client = Shove.app.connect("unique_id")

# create a client, on a different app, without
# having an app_key.  Used for simple subscriptions
app = Shove::App.new do
  app_id "myappid"
end

client = app.connect("dan@shove.io")
```

Working with connection events

```ruby
# listen for a connection event
client.on("connect") do
  # connected
end

client.on("connect_denied") do |id|
  # Silly but good example:
  Shove.client(id).grant_connect do |response|
    # magic
  end
end

client.on("disconnect") do
end

client.on("error") do |error|
end
```

### Working With Channels - Subscribing

```ruby
client = Shove.app.connect

# subscribe to a channel, or get's it's
# context
channel = client.channel("channel")

channel.on("subscribe") do
  # channel is subscribed
end

channel.on("subscribe_denied") do
  # not permitted, request auth from
  # another service
  Shove.client(client.id).grant_subscribe(channel.name)
end

# bind the message event to a block
# callback
channel.on("message") do |msg|
end

# if you want to cancel a callback, store
# it's binding
binding = channel.on("message") do |msg|
end

binding.cancel

# handle events on the direct channel
client.channel("direct").on("message") do |msg|
  # handle direct message
end
```

### Channels - Unsubscribing

```ruby
channel.on("unsubscribe_complete") do
end

channel.unsubscribe
```

### Channels - Publishing

```ruby
# publish a simple string
channel.publish("hi!")

# publish json
channel.publish(obj.to_json)
```

Using the Command Line
----------------------


[0]: http://shove.io/customer/network/api_access
[1]: http://shove.io/documentation/cli