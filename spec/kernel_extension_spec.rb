
require 'core_ext/kernel'

describe Kernel, "missing methods extension" do
  it "should be able to handle a non-case" do
    self.should_not respond_to(:foo_bar)
    lambda{ foo_bar }.should raise_error(NameError)
  end

  it "should be able to handle the simple case" do
    self.should_not respond_to(:foo)
    lambda{ foo }.should raise_error(NameError)
  end

  it "should not try if the method exists" do
    self.should_receive(:foo_bar)
    self.should_not_receive(:fooBar)
    self.foo_bar
  end

  it "should try to camelcase the method name" do
    self.should_not respond_to(:foo_bar_baz)
    self.should_receive(:fooBarBaz)
    self.foo_bar_baz
  end

  it "should not forget parameters" do
    self.should_not respond_to(:foo_bar)
    self.should_receive(:fooBar).with("baz")
    self.foo_bar("baz")
  end

  it "should correctly return values" do
    self.should_not respond_to(:foo_bar)
    self.should_receive(:fooBar).with("baz").and_return("baf")
    self.foo_bar("baz").should == "baf"
  end

  it "should correctly handle blocks" do
    pending
  end

  it "should find camelcased setters" do
    self.should_not respond_to(:foo_bar=)
    self.should_receive(:setFooBar).with("baz")
    self.foo_bar = "baz"
  end

  it "should find is* boolean methods" do
    self.should_not respond_to(:foo_bar?)
    self.should_receive(:isFooBar).with("baz")
    self.foo_bar? "baz"
  end

  it "should find has* boolean methods" do
    self.should_not respond_to(:foo_bar?)
    self.should_receive(:hasFooBar).with("baz")
    self.foo_bar? "baz"
  end
end
