require File.dirname(__FILE__) + "/helper"

describe Shove::Client do

  before(:all) do 
    Shove.configure do
      app_id "test"
      app_key "test"
      api_url "http://api.shove.dev:8080"
      ws_url "ws://shove.dev:9000"
    end
  end

  before do |context|
    VCR.insert_cassette context.example.metadata[:description_args].first
    $queue.clear
  end

  after do |context|
    VCR.eject_cassette
  end

  it "should spawn a client" do
    @client = Shove.app.connect
    @client.should_not == nil
    @client.url.should == "#{Shove.config.ws_url}/test"
  end

  it "should send a connect op" do
    @client = Shove.app.connect
    message = $queue.pop
    message["opcode"].should == Shove::Protocol::CONNECT
  end

  it "should send a connect op with an id" do
    @client = Shove.app.connect("monkey")
    message = $queue.pop
    message["opcode"].should == Shove::Protocol::CONNECT
    message["data"].should == "monkey"
  end

  it "should trigger a connect event" do
    @client = Shove.app.connect
    @client.on("connect") do |client_id|
      @triggered = true
      @id = client_id
    end

    backdoor :opcode => Shove::Protocol::CONNECT_GRANTED, :data => "tid"

    @id.should == "tid"
    @triggered.should == true
  end

  it "should trigger a connect_denied event" do
    @client = Shove.app.connect
    @client.on("connect_denied") do |client_id|
      @triggered = true
      @id = client_id
    end

    backdoor :opcode => Shove::Protocol::CONNECT_DENIED, :data => "tid"

    @id.should == "tid"
    @triggered.should == true
  end


  it "should trigger a disconnect event" do
    @client = Shove.app.connect
    @client.on("disconnect") do
      @triggered = true
    end

    backdoor :opcode => Shove::Protocol::DISCONNECT

    @triggered.should == true
  end

  it "should trigger an error event" do
    @client = Shove.app.connect
    @client.on("error") do |error|
      @error = error
    end

    backdoor :opcode => Shove::Protocol::ERROR, :data => "Test Error"

    @error.should == "Test Error"
  end

  it "should authorize oneself" do
    @client = Shove.app.connect
    @client.authorize("test")
    $queue.last()["opcode"].should == Shove::Protocol::AUTHORIZE
  end

  it "should create a channel context" do
    @client = Shove.app.connect
    @channel = @client.channel("channel")

    @channel.should_not == nil
    @channel.should == @client.channel("channel")
  end

  it "should subscribe to a channel" do
    @client = Shove.app.connect
    @channel = @client.channel("channel")
    @message = $queue.last
    @message["opcode"].should == Shove::Protocol::SUBSCRIBE
  end

  it "should get a subscribe granted event" do
    @client = Shove.app.connect
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

    @client = Shove.app.connect
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

    @client = Shove.app.connect
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
    @client = Shove.app.connect
    @channel = @client.channel("channel")
    @channel.unsubscribe
    @message = $queue.last
    @message["opcode"].should == Shove::Protocol::UNSUBSCRIBE
  end

  it "should receive an unsubscribe event" do
    @client = Shove.app.connect
    @channel = @client.channel("channel")
    @channel.unsubscribe
    @channel.on("unsubscribe") do
      @triggered = true
    end

    backdoor :opcode => Shove::Protocol::UNSUBSCRIBE_COMPLETE, :channel => "channel"

    @triggered.should == true
  end


  it "should publish" do
    @client = Shove.app.connect
    @channel = @client.channel("channel")
    @channel.publish "test"

    $queue.last()["opcode"].should == Shove::Protocol::PUBLISH
  end

end