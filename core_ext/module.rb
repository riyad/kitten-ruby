
require 'core_ext/kernel'

require 'Qt4'

module ModuleExtension
  def self.included(base)
    # attr_accessor
    base.send :alias_method, :attr_accessor_without_camelize, :attr_accessor
    base.send :alias_method, :attr_accessor, :attr_accessor_with_camelize

    # attr_reader
    base.send :alias_method, :attr_reader_without_camelize, :attr_reader
    base.send :alias_method, :attr_reader, :attr_reader_with_camelize

    # attr_writer
    base.send :alias_method, :attr_writer_without_camelize, :attr_writer
    base.send :alias_method, :attr_writer, :attr_writer_with_camelize
  end

  private

  def attr_accessor_with_camelize(*symbols)
    attr_reader(*symbols)
    attr_writer(*symbols)
  end

  def attr_reader_with_camelize(*symbols)
    return attr_reader_without_camelize(*symbols) unless ancestors.include? Qt::Object

    # generates the attribute writers
    symbols.each do |sym|
      attr_name = sym.id2name
      method_name = attr_name

      camelized_method_names = [] # readers can be ambiguous
      [method_name, "#{method_name}?"].each do |variant|
        camelized_method_names += camelize_method_name(variant)
      end
      camelized_method_names.reject! { |camelized_method_name| camelized_method_name == method_name }

      p "#{method_name}: #{camelized_method_names.inspect}"

      # generates the method with customized behaviour only if the name differs
      # if there is a fooBarBaz/isFooBarBaz/hasFooBarBaz method it will be called
      # otherwise standard behaviour is ensured
      module_eval <<-END
        def #{method_name}()
          #{camelized_method_names.inspect}.each do |camelized_method_name|
            if respond_to? camelized_method_name
              return send camelized_method_name.to_sym
            end
          end

          @#{attr_name}
        end
      END
    end
  end

  def attr_writer_with_camelize(*symbols)
    return attr_writer_without_camelize(*symbols) unless ancestors.include? Qt::Object

    # generates the attribute writers
    symbols.each do |sym|
      attr_name = sym.id2name
      method_name = "#{attr_name}="
      camelized_method_name = camelize_method_name(method_name)[0] # setters should be unambiguous

      # generates the method with customized behaviour
      # if there is a setFoo method it will be called otherwise standard behaviour is ensured
      module_eval <<-END
        def #{method_name}(val = nil)
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
