shove ruby client
=================
Ruby client and CLI for the shove.io HTTP and WebSocket APIs

Installation
------------

```bash
gem install shove
```

Grab your App ID and App Key from shove at [https://shove.io/apps][0]

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

Using the HTTP Client
---------------------
The HTTP client gives publishing and access control capabilities without
a persistent WebSocket connection

Publish "Hello World!" to all connections on the notifications channel

```ruby
Shove.channel("notifications").publish("Hello World!") do |response|
  # handle response
end
```

Publish "Hey buddy" to the client with id buddy.

```ruby
Shove.channel("direct:buddy").publish("Hey buddy") do |response|
  # handle response
end
```

Apps, channels, and clients can be controlled from the HTTP API

Grant a connection to dan@shove.io

```ruby
Shove.grant_connect("dan@shove.io") do |response|
  # handle response
end
```

Grant subscription on the notifications channel to client dan

```ruby
Shove.channel("notifications").grant_subscribe("dan") do |response|
  # handle response
end
```

Grant subscription on all channels to client dan

```ruby
Shove.channel("*").grant_subscribe("dan@shove.io") do |response|
  # handle response
end
```

Grant publishing on chat:client_22733 channel to client dan

```ruby
Shove.channel("chat:client_22733").grant_publish("dan") do |response|
  # handle response
end
```

Deny publishing on chat:client_22733 channel to dan

```ruby
Shove.channel("chat:client_22733").deny_publish("dan") do |response|
  # handle response
end
```

Using the WebSocket Client
--------------------------

Create a WebSocket client on the default app

```ruby
client = Shove.app.connect
```

Or

```ruby
app = Shove::App.new do
  app_id "myappid"
end
client = app.connect
```

Create a client with a custom ID

```ruby
client = Shove.app.connect("unique_id")
```

### Client events

Handle connect event

```ruby
client.on("connect") do
  # Connected!
end
```

Handle connect denies (private app)

```ruby
client.on("connect_denied") do |id|
  # Silly, but:
  Shove.client(id).grant_connect do |response|
    # At this point, the client should receive
    # a connect event (through the shove app)
  end
end
```

And disconnect events

```ruby
client.on("disconnect") do
end
```

If there is any kind of error, log it

```ruby
client.on("error") do |error|
  log.error "Shove error: #{error}"
end
```

### Clients and Channels

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
  # Silly example
  Shove.client(client.id).grant_subscribe(channel.name)
end
```

You can get the binding for a callback and cancel it

```ruby
binding = channel.on("message") do |msg|
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

Note: if you don't have the app key speficied for the app, the
channel key generated will not be correct.

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

[0]: https://shove.io/apps
[1]: http://shove.io/documentation/cli