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

  it "should spawn a client" do
    EM.run do
      @client = Shove.app.connect
      @client.on("connect") do
        @client.id.should_not == nil
        EM.stop
      end
    end
  end

  it "should spawn a client with allowed id" do
    EM.run do
      @client = Shove.app.connect("mark")
      @client.on("connect") do
        @client.id.should == "mark"
        EM.stop
      end
    end
  end

  #TODO:
  #Channels
  #Pub
  #Sub

end