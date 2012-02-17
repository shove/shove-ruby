require File.dirname(__FILE__) + "/helper"

module Shove

  # Mock standard in (for CLI app)
  class MockStdin

    def initialize *msgs
      @msgs = msgs
    end

    def gets
      "#{@msgs.shift}\r\n"
    end

  end

  describe AppDirectory do

    before do |context|
      VCR.insert_cassette context.example.metadata[:description_args].first
    end

    after do |context|
      VCR.eject_cassette
    end

    it "should configure the default" do
      system "rm /tmp/shove.yml"
      dir = AppDirectory.new(MockStdin.new("test","test"), "/tmp/shove.yml")
      config = dir.default
      config[:app_id].should == "test"
      config[:app_key].should == "test"
      FileTest.exist?("/tmp/shove.yml").should == true
    end

    it "should configure the from the previous test" do
      dir = AppDirectory.new(MockStdin.new, "/tmp/shove.yml")
      config = dir.get_config "test"
      config[:app_id].should == "test"
      config[:app_key].should == "test"
    end

    it "should save an app" do
      dir = AppDirectory.new(MockStdin.new, "/tmp/shove.yml")
      dir.put "id1", "key1"
      dir.put "id2", "key2"
      dir.put "id3", "key3"
      dir.apps.size.should == 4
    end

    it "should update an app" do
      dir = AppDirectory.new(MockStdin.new, "/tmp/shove.yml")
      dir.put "id2", "key9"
      dir.key("id2").should == "key9"
    end

    it "should update the default app" do
      dir = AppDirectory.new(MockStdin.new, "/tmp/shove.yml")
      dir.default = "id2"
      dir.app.should == "id2"
      dir.default()[:app_key].should == "key9"
    end

  end
end