
require 'core_ext/module'

describe Module, "attribute" do
  context "writer extionsion" do
    it "should overwrite attr_writer" do
      Module.private_methods.should include('attr_writer_with_camelize')
      Module.private_methods.should include('attr_writer_without_camelize')
    end

    it "should generate setter methods" do
      self.should_not respond_to(:foo=)
      class Foo
        attr_writer :foo
      end
      a = Foo.new
      a.should respond_to(:foo=)
    end

    it "should generate setter methods respecting camelcased equivalents" do
      self.should_not respond_to(:foo=)
      class Foo
        attr_writer :foo
      end
      a = Foo.new
      a.should respond_to(:foo=)
    end
  end
end
