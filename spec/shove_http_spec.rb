require File.dirname(__FILE__) + "/helper"

describe Shove::Http do

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
  end

  after do |context|
    VCR.eject_cassette
  end

  it "should have a version" do
    Shove.const_defined?("Version").should == true
  end

  
  it "should be able to authorize with the server" do
    valid = @app.valid?
    valid.should == true
  end
    
  it "should get a set of nodes for the network" do
    hosts = @app.hosts
    hosts.size.should > 0
  end
  
  # Channel context tests, basic plumbing

  it "should spawn a channel context" do
    chan = @app.channel("test")
    chan.channel.should == "test"
    chan.app.should == @app
  end

  it "should publish on a channel context" do
    @app.channel("test").publish("hi") do |response|
      response.error?.should == false
    end
  end

  it "should grant subscriptions on a channel context" do
    @app.channel("test").grant_subscribe("dan") do |response|
      response.error?.should == false
    end
  end

  it "should grant publishing on a channel context" do
    @app.channel("test").grant_publish("dan") do |response|
      response.error?.should == false
    end
  end

  it "should deny subscriptions on a channel context" do
    @app.channel("test").deny_subscribe("dan") do |response|
      response.error?.should == false
    end
  end

  it "should deny publishing on a channel context" do
    @app.channel("test").deny_publish("dan") do |response|
      response.error?.should == false
    end
  end
 
  # Client context tests, basic plumbing

  it "should spawn a client context" do
    chan = @app.client("dan")
    chan.id.should == "dan"
    chan.app.should == @app
  end

  it "should grant a connection" do
    @app.client("dan").grant_connect do |response|
      response.error?.should == false
    end
  end

  it "should deny a connection" do
    @app.client("dan").deny_connect do |response|
      response.error?.should == false
    end
  end

  it "should publish to a client" do
    @app.client("dan").publish("hi") do |response|
      response.error?.should == false
    end
  end

  it "should grant a subscriptions to a client" do
    @app.client("dan").grant_subscribe("channel") do |response|
      response.error?.should == false
    end
  end

  it "should grant a publishing to a client" do
    @app.client("dan").grant_publish("channel") do |response|
      response.error?.should == false
    end
  end

  it "should grant a control to a client" do
    @app.client("dan").grant_control do |response|
      response.error?.should == false
    end
  end

  it "should deny a subscriptions to a client" do
    @app.client("dan").deny_subscribe("channel") do |response|
      response.error?.should == false
    end
  end

  it "should deny a publishing to a client" do
    @app.client("dan").deny_publish("channel") do |response|
      response.error?.should == false
    end
  end

  it "should deny a control to a client" do
    @app.client("dan").deny_control do |response|
      response.error?.should == false
    end
  end


end
