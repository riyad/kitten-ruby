
require 'core_ext/module'

describe Module, "attribute" do
  context "accessor extension" do
    it "should overwrite attr_accessor" do
      Module.private_methods.should include('attr_accessor_with_camelize')
      Module.private_methods.should include('attr_accessor_without_camelize')
    end

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

  context "reader extension" do
    it "should overwrite attr_reader" do
      Module.private_methods.should include('attr_reader_with_camelize')
      Module.private_methods.should include('attr_reader_without_camelize')
    end

    it "should generate reader methods" do
      class FooBarBazGetterResponseTest
        attr_reader :foo_bar_baz
      end
      a = FooBarBazGetterResponseTest.new

      a.should respond_to(:foo_bar_baz)
    end

    it "should fall back correctly" do
      class FooBarBazReaderFallBackTest
        attr_reader :foo_bar_baz
      end
      a = FooBarBazReaderFallBackTest.new

      a.instance_variable_set('@foo_bar_baz', "boo")
      a.foo_bar_baz.should == "boo"
    end

    it "should generate reader methods respecting general camelcased equivalent" do
      class FooBarBazReaderAlteredGeneralResponseTest
        attr_reader :foo_bar_baz
      end
      a = FooBarBazReaderAlteredGeneralResponseTest.new

      a.should_receive(:fooBarBaz).and_return("boo")

      a.foo_bar_baz.should == "boo"
    end

    it "should generate reader methods respecting is* camelcased equivalent" do
      class FooBarBazReaderAlteredIsBoolResponseTest
        attr_reader :foo_bar_baz
      end
      a = FooBarBazReaderAlteredIsBoolResponseTest.new

      a.should_receive(:isFooBarBaz).and_return("boo")

      a.foo_bar_baz.should == "boo"
    end

    it "should generate reader methods respecting has* camelcased equivalent" do
      class FooBarBazReaderAlteredHAsBoolResponseTest
        attr_reader :foo_bar_baz
      end
      a = FooBarBazReaderAlteredHAsBoolResponseTest.new

      a.should_receive(:hasFooBarBaz).and_return("boo")

      a.foo_bar_baz.should == "boo"
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

    it "should fall back correctly" do
      class FooBarBazWriterFallBackTest
        attr_writer :foo_bar_baz
      end
      a = FooBarBazWriterFallBackTest.new

      a.foo_bar_baz = "boo"
      a.instance_variable_get('@foo_bar_baz').should == "boo"
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
