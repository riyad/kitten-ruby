
require 'core_ext/module'

describe Module, "attribute" do
  context "accessor extension" do
    it "should call attr_reader" do
      class FooAccessorReaderCallTest
        should_receive(:attr_reader)
        attr_accessor :foo
      end
    end

    it "should call attr_writer" do
      class FooAccessorWriterCallTest
        should_receive(:attr_writer)
        attr_accessor :foo
      end
    end
  end

  context "writer extension" do
    it "should overwrite attr_writer" do
      Module.private_methods.should include('attr_writer_with_camelize')
      Module.private_methods.should include('attr_writer_without_camelize')
    end

    it "should generate writer methods" do
      class FooBarBazWriterResponseTest
        attr_writer :foo_bar_baz
      end
      a = FooBarBazWriterResponseTest.new

      a.should respond_to(:foo_bar_baz=)
    end

    it "should generate writer methods respecting camelcased equivalents" do
      class FooBarBazWriterAlteredResponseTest
        attr_writer :foo_bar_baz
      end
      a = FooBarBazWriterAlteredResponseTest.new

      a.should_receive(:setFooBarBaz)

      a.foo_bar_baz = "boo"
    end
  end
end
