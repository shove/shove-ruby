shove
=====
HTTP and WebSocket clients for shove.io

<a name="installation"></a>
Installation
------------

```bash
gem install shove
```

<a name="configuration"></a>
Using Shove
-----------

To use shove, you must first create a Shove::App object.

```ruby
app = Shove::App.new(
  app_id: "myappid",
  app_key: "myappkey"
)
```

Get your app_id, and app_key at [shove.io][0]

<a name="http_client"></a>
Using the HTTP Client
---------------------
The HTTP client gives publishing and access control capabilities without
a persistent WebSocket connection.  The HTTP client cannot act as a subscriber.

Publish to a channel

```ruby
app.channel("notifications").publish("Hello World!")
```

Publish Direct

```ruby
app.channel("direct:buddy").publish("Hey buddy")
```

Publish and handle the HTTP response

```ruby
app.channel("notifications").publish("...") do |response|
  if reponse.error?
    puts "#{response.status} - #{response.error}"
  end
end
```

You can control access to your apps and channels, allowing for
granular security.

Grant subscription on the notifications channel

```ruby
app.channel("notifications").grant_subscribe("dan@shove.io")
```

Grant subscription on all channels to client dan

```ruby
app.channel("*").grant_subscribe("dan@shove.io")
```

Grant publishing on chat:client_22733 channel to client dan

```ruby
app.channel("chat:client_22733").grant_publish("dan")
```

Deny publishing on chat:client_22733 channel to dan

```ruby
app.channel("chat:client_22733").deny_publish("dan")
```

Sometimes it's easier to give out an access key to a specific
channel, which is also an option.

<a name="channel_keys"></a>
Channel Keys
------------
You can generate channel keys which allow clients of
your shove network to subscribe or publish to specific
channels.

Example: Create a key for the channel groups:788

```ruby
key = app.channel_key "group:788"
```

Subscribe only

```ruby
key = app.subscribe_key "group:788"
```

This functionality becomes useful when you want to give
you site users access.  In your view:

```erb
var channel = "<%= @channel %>";
var key = "<%= @app.channel_key(@channel) %>";
```

Note: Channel keys are based off the app key (master key).  So, in order for
them to work, you must specify the app key in your app.

```ruby
app = Shove::App.new(
  app_id: "myappid",
  app_key: "myappkey"
)
```

<a name="websocket_client"></a>
Using the WebSocket Client
--------------------------
You can also use the gem to run a persistent client.  This
requires that you are running an EventMachine reactor.

```ruby
EM.run do
  app = Shove::App.new(
    app_id "myapp",
    app_key: "myappkey"
  )

  client = app.connect
end
```

### Client events

Connect event:

```ruby
client.on("connect") do
  # Connected!
end
```

Disconnect event:

```ruby
client.on("disconnect") do
  # disconnect code
end
```

Error event:

```ruby
client.on("error") do |error|
  log.error "Shove error: #{error}"
end
```

Connect denied event: (don't forget to authorize)

```ruby
client.on("connect_denied") do |id|
  client.authorize
end
```

### Channels & Publish and Subscribe

Subscribe to a channel or get a subscribed channel

```ruby
channel = client.channel("channel")
```

Handle a message published on a channel

```ruby
channel.on("message") do |msg|
  widget.append msg
end
```

Handle the subscribe callback for a given channel

```ruby
channel.on("subscribe") do
  # channel is subscribed
end
```

If the app denies subscriptions by default, you should
handle the subscribe_denied event

```ruby
channel.on("subscribe_denied") do
  channel.authorize "key"
  channel.subscribe
end
```

You can get the binding for a callback and cancel it

```ruby
binding = channel.on("message") do |msg|
  # important stuff here
end

binding.cancel
```

Handle a direct message

```ruby
client.channel("direct").on("message") do |msg|
  # handle direct message
end
```

Unsubscribe from a channel, optionally handle the event

```ruby
channel.on("unsubscribe_complete") do
end

channel.unsubscribe
```

Publish a message from the WebSocket client

```ruby
channel.publish("hi!")

# publish json
channel.publish(obj.to_json)
```

<a name="websocket_client"></a>
WebSocket Client without App Key
--------------------------------
If you are connecting to someone elses app
and have limited scope and access, you can get by.

```ruby
EM.run do
  app = Shove::App.new(
    app_id "myapp"
  )

  client = app.connect "connect-key"

  channel = client.channel("channel")
  channel.auth "channelkey"

  channel.on("message") do |message|
    puts message
  end
end
```

[0]: https://shove.io
[1]: https://shove.io