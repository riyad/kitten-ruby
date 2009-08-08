
module Kernel
  def method_missing(symbol, *args, &block)
    # First look for a method in the Smoke runtime
    # If not found, then throw an exception and try again in the ruby runtime.
    super
  rescue
    name = symbol.id2name

    possible_names = camelize_method_name(name)

    possible_names.each do |name|
      if respond_to?(name, true)
        return send(name.to_sym, *args, &block)
      end
    end

    raise
  end

  private

  def camelize_method_name(name)
    # Make 'parrot.age = 7' a synonym for 'parrot.setAge(7)'
    name = 'set' + $1.upcase + $2 if name =~ /(.)(.*[^-+%\/|])=$/

    # If the method name contains underscores, convert to camel case
    while name =~ /([^_]*)_(.)(.*)/
        name = $1 + $2.upcase + $3
    end

    # TODO: Make thing? a synonym for isThing() or hasThing()
    if name =~ /(.)(.*)\?$/
      name = $1.upcase + $2
      ["is#{name}", "has#{name}"]
    else
      [name]
    end
  end
end
