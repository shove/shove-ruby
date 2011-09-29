require File.dirname(__FILE__) + "/helper"

describe Shove do

  before do
    Shove.configure "shove.yml"
  end

  it "should have a version" do
    Shove.const_defined?("Version").should == true
  end

  it "should have config" do
    Shove.config[:app].should == "test"
    Shove.config[:key].should == "test"
  end
  
  it "should be able to authorize with the server" do
    valid = Shove.validate
    valid.should == true
  end
    
  it "should get a set of nodes for the network" do
    hosts = Shove.hosts
    hosts.size.should > 0
  end
  
  it "should be able to broadcast a message" do
    Shove.broadcast("default", "event", "test") do |response|
      response.error?.should == false
    end
  end
    
  it "should be able to broadcast a message with EM" do
    EM.run do
      Shove.broadcast("default", "event", "test2") do |response|
        response.error?.should == false
      end
      
      EM.add_timer(0.2) do
        EM.stop
      end
    end
  end
  
  
  it "should stream like a boss" do
    EM.run do
    
      messages = []
      
      subscriber = Shove.subscriber
      subscriber.connect
      
      subscriber.on("default", "tev") do |msg|
        messages << msg
      end
      
      EM.add_timer(0.2) do
        Shove.broadcast("default", "tev", "test") do |response|
          response.error?.should == false
        end
      end
      
      EM.add_timer(0.5) do
        messages.size.should == 1
        EM.stop
      end
    end
  end

end
