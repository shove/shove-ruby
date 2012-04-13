shove ruby client
=================
Ruby client and CLI for the shove.io HTTP and WebSocket APIs

<a name="installation"></a>
Installation
------------

```bash
gem install shove
```

<a name="configuration"></a>
Configuring Shove
-----------------

If you are using a single shove app within your project, you can configure
shove though the Shove module:

```ruby
Shove.configure do
  app_id "myappid"
  app_key "myappkey"
end
```

If you want to work with different shove apps in one project, you can 
create App objects

```ruby
app = Shove::App.new do
  app_id "myappid"
  app_key "myappkey"
end
```

Grab your App ID and App Key from shove: [https://shove.io][0]

<a name="http_client"></a>
Using the HTTP Client
---------------------
The HTTP client gives publishing and access control capabilities without
a persistent WebSocket connection.  The HTTP client does not act as a subscriber.

Simple Publish

```ruby
Shove.channel("notifications").publish("Hello World!")
```

Publish Direct

```ruby
Shove.channel("direct:buddy").publish("Hey buddy")
```

Publish and handle the HTTP response

```ruby
Shove.channel("notifications").publish("...") do |response|
  if reponse.error?
    puts "#{response.status} - #{response.error}"
  end
end
```

You can control access to your apps and channels, allowing for
granular security.

Grant subscription on the notifications channel

```ruby
Shove.channel("notifications").grant_subscribe("dan@shove.io")
```

Grant subscription on all channels to client dan

```ruby
Shove.channel("*").grant_subscribe("dan@shove.io")
```

Grant publishing on chat:client_22733 channel to client dan

```ruby
Shove.channel("chat:client_22733").grant_publish("dan")
```

Deny publishing on chat:client_22733 channel to dan

```ruby
Shove.channel("chat:client_22733").deny_publish("dan")
```

Sometimes it's easier to give out an access key to a specific
channel, which is also an option.

<a name="channel_keys"></a>
Channel Keys
------------
You can generate channel keys which allow clients of
your shove network to publish and subscribe to specific
channels.

Example: Create a key for the channel groups:788

```ruby
key = Shove.channel_key "group:788"
```

If it's for a particular App, use:

```ruby
key = app.channel_key "group:788"
```

This functionality becomes useful when you want to give
you site users access.  A little haml for you:

```haml
:javascript
  var channel = "#{@channel}";
  var key = "#{@shove.channel_key(@channel)}";
```

Note: Channel keys are based off the app key.  So, in order for
them to work, you must specify the app key:

```ruby
  Shove.configure do
    app_key "key"
  end
```

<a name="websocket_client"></a>
Using the WebSocket Client
--------------------------
You can also use the gem to run a persistent client.  This
requires that you are running an EventMachine reactor.

```ruby
EM.run do
  app = Shove::App.new do
    app_id "myapp"
  end

  app.connect

  # alternatively, supply your user id
  client = app.connect "unique_id"
end
```

### Authorization
The client is treated like any other websocket
client and must be authorized to publish and subscribe.

```ruby
client.authorize "app_key"

# self authorize a particular channel
client.channel("channel").authorize "channel_key"
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

### Publish and Subscribe

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

Using the Command Line
----------------------

A CLI utility is included with the gem, run help to see options

```bash
shove help
```

Publish a message

```bash
shove publish -c channel1 -m "Hello world!"
```

Publish to a specific app

```bash
shove publish -a app_id -c chan1 -m "hi"
```

Set the default app for the CLI

```bash
shove apps:default -a app_id
```

Watch all activity on a channel

```bash
shove watch -c chan
```

[0]: https://shove.io
[1]: https://shove.io