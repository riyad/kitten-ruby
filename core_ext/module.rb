
require 'core_ext/kernel'

module ModuleExtension
  def self.included(base)
    # attr_accessor
    base.send :alias_method, :attr_accessor_without_camelize, :attr_accessor
    base.send :alias_method, :attr_accessor, :attr_accessor_with_camelize

    # attr_writer
    base.send :alias_method, :attr_writer_without_camelize, :attr_writer
    base.send :alias_method, :attr_writer, :attr_writer_with_camelize
  end

  private

  def attr_accessor_with_camelize(*symbols)
    attr_reader(*symbols)
    attr_writer(*symbols)
  end

  def attr_writer_with_camelize(*symbols)
    # generates the attribute writers
    symbols.each do |sym|
      attr_name = sym.id2name
      method_name = "#{attr_name}="
      camelized_method_name = camelize_method_name(method_name)[0] # setters should be unambiguous

      # overwrites the already generated method with a customized one
      # if there is a setFoo method it will be called otherwise standard behaviour is ensured
      module_eval <<-END
        def #{method_name}(val)
          if respond_to? :#{camelized_method_name}
            #{camelized_method_name}(val)
          else
            @#{attr_name} = val
          end
        end
      END
    end
  end
end

class Module
  include ModuleExtension
end
