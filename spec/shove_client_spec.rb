require File.dirname(__FILE__) + "/helper"

describe Shove::Client do

  before(:all) do 
    @app = Shove::App.new(
      app_id: "test",
      app_key: "test",
      api_url: "http://api.shove.dev:8000",
      ws_url: "ws://shove.dev:9000"
    )
  end

  before do |context|
    VCR.insert_cassette context.example.metadata[:description_args].first
    $queue.clear
  end

  after do |context|
    VCR.eject_cassette
  end

  it "should spawn a client" do
    @client = @app.connect
    @client.should_not == nil
    @client.url.should == "#{@app.ws_url}/test"
  end

  it "should send a connect op" do
    @client = @app.connect
    message = $queue.shift
    message["opcode"].should == Shove::Protocol::CONNECT
  end

  it "should self authorize if key is set" do
    @client = @app.connect
    message = $queue.pop
    message["opcode"].should == Shove::Protocol::AUTHORIZE
  end

  it "should trigger a connect event" do
    @client = @app.connect
    @client.on("connect") do |client_id|
      @triggered = true
      @id = client_id
    end

    backdoor :opcode => Shove::Protocol::CONNECT_GRANTED, :data => "tid"

    @id.should == "tid"
    @triggered.should == true
  end

  it "should trigger a connect_denied event" do
    @client = @app.connect
    @client.on("connect_denied") do |client_id|
      @triggered = true
      @id = client_id
    end

    backdoor :opcode => Shove::Protocol::CONNECT_DENIED, :data => "tid"

    @id.should == "tid"
    @triggered.should == true
  end


  it "should trigger a disconnect event" do
    @client = @app.connect
    @client.on("disconnect") do
      @triggered = true
    end

    backdoor :opcode => Shove::Protocol::DISCONNECT

    @triggered.should == true
  end

  it "should trigger an error event" do
    @client = @app.connect
    @client.on("error") do |error|
      @error = error
    end

    backdoor :opcode => Shove::Protocol::ERROR, :data => "Test Error"

    @error.should == "Test Error"
  end

  it "should authorize oneself" do
    @client = @app.connect
    @client.auth!
    $queue.last()["opcode"].should == Shove::Protocol::AUTHORIZE
  end

  it "should create a channel context" do
    @client = @app.connect
    @channel = @client.channel("channel")

    @channel.should_not == nil
    @channel.should == @client.channel("channel")
  end

  it "should subscribe to a channel" do
    @client = @app.connect
    @channel = @client.channel("channel")
    $queue.last["opcode"].should_not == Shove::Protocol::SUBSCRIBE
    @channel.on("message") do
    end
    $queue.last["opcode"].should == Shove::Protocol::SUBSCRIBE
  end

  it "should get a subscribe granted event" do
    @client = @app.connect
    @channel = @client.channel("channel")
    @channel.on("subscribe") do
      @triggered = true
    end

    backdoor :opcode => Shove::Protocol::SUBSCRIBE_GRANTED, :channel => "channel"

    @triggered.should == true
  end

  it "should receive messages on a channel" do
    @messages = 0
    @message = nil

    @client = @app.connect
    @channel = @client.channel("channel")
    @channel.on("message") do |msg|
      @messages += 1
      @message = msg
    end

    backdoor :opcode => Shove::Protocol::PUBLISH, :channel => "channel", :data => "test"

    @messages.should == 1
    @message.should == "test"
  end

  it "should cancel a binding" do
    @messages = 0

    @client = @app.connect
    @channel = @client.channel("channel")
    binding = @channel.on("message") do |msg|
      @messages += 1
    end

    message = { 
      :opcode => Shove::Protocol::PUBLISH, 
      :channel => "channel", 
      :data => "test" 
    }

    backdoor message
    backdoor message
    binding.cancel
    backdoor message

    @messages.should == 2
  end

  it "should unsubscribe from a channel" do
    @client = @app.connect
    @channel = @client.channel("channel")
    @channel.unsubscribe
    @message = $queue.last
    @message["opcode"].should == Shove::Protocol::UNSUBSCRIBE
  end

  it "should receive an unsubscribe event" do
    @client = @app.connect
    @channel = @client.channel("channel")
    @channel.unsubscribe
    @channel.on("unsubscribe") do
      @triggered = true
    end

    backdoor :opcode => Shove::Protocol::UNSUBSCRIBE_COMPLETE, :channel => "channel"

    @triggered.should == true
  end


  it "should publish" do
    @client = @app.connect
    @channel = @client.channel("channel")
    @channel.publish "test"

    $queue.last()["opcode"].should == Shove::Protocol::PUBLISH
  end

  it "should generate a channel key" do
    key = @app.channel_key "money"
    key.should == "5cf0a03b439091a07eb544832fc11c62f0b1af17"
  end

  it "should generate a subscribe key" do
    key = @app.subscribe_key "money"
    key.should == "6f78f2ba414a482fc5c45eb080d8877ddf1fc6ba"
  end

  it "should generate a publish key" do
    key = @app.publish_key "money"
    key.should == "5cf0a03b439091a07eb544832fc11c62f0b1af17"
  end

  it "should authorize on a channel" do
    @client = @app.connect
    @channel = @client.channel("channel")
    @channel.authorize "key"

    item = $queue.last()

    item["opcode"].should == Shove::Protocol::AUTHORIZE
    item["data"].should == "key"
    item["channel"].should == "channel"

    @triggered = false
    @channel.on("authorize_complete") do
      @triggered = true
    end

    backdoor :opcode => Shove::Protocol::AUTHORIZE_COMPLETE, :channel => "channel"

    @triggered.should == true
  end

end