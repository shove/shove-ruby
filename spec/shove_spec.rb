require File.dirname(__FILE__) + "/helper"

describe Shove do

  before do
    Shove.configure "shove.yml"
  end

  it "should have a version" do
    Shove.const_defined?("Version").should == true
  end

  it "should have config" do
    Shove.config[:network].should == "deadbeef"
  end
  
  it "should be able to authorize with the server" do
    response = Shove.validate
    response.error?.should == false
  end
  
  it "should get a set of hosts for the network" do
    response = Shove.hosts
    response.status.should == 200
  end
  
  it "should be able to broadcast a message" do
    Shove.broadcast("default", "event", "test") do |response|
      response.error?.should == false
    end
  end
    
  it "should be able to broadcast a message with EM" do
    EM.run do
    
      ##
      # Setup stream and capture for validation
      ##
    
      Shove.broadcast("default", "event", "test2") do |response|
        response.error?.should == false
      end
      
      EM.add_timer(0.2) do
          EM.stop
      end
    end
  end

end
