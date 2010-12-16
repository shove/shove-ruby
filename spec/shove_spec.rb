require File.dirname(__FILE__) + "/helper"

describe Shove do

  before do
    Shove.configure "./shove.yml"
  end

  it "should have a version" do
    Shove.const_defined?("Version").should == true
  end

  it "should have config" do
    Shove.config["network"].should == "shove"
  end

end
