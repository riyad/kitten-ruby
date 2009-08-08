
require 'core_ext/kernel'

class Module
  def attr_writer(*symbols)
    symbols.each do |sym|
      attr_name = sym.id2name
      method_name = "#{attr_name}="
      camelized_method_name = camelize_method_name(method_name)[0] # setters should be unambiguous
      p "Generating #{method_name} for #{attr_name} with respect to #{camelized_method_name}"
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
