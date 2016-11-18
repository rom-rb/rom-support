module ROM
  # Internal support module for class-level settings
  #
  # @private
  module ClassMacros
    UndefinedValue = Object.new

    # Specify what macros a class will use
    #
    # @example
    #   class MyClass
    #     extend ROM::ClassMacros
    #
    #     defines :one, :two
    #
    #     one 1
    #     two 2
    #   end
    #
    #   class OtherClass < MyClass
    #     two 'two'
    #   end
    #
    #   MyClass.one # => 1
    #   MyClass.two # => 2
    #
    #   OtherClass.one # => 1
    #   OtherClass.two # => 'two'
    #
    # @api private
    def defines(*args)
      mod = Module.new do
        args.each do |name|
          define_method(name) do |value = UndefinedValue|
            ivar = "@#{name}"
            if value == UndefinedValue
              instance_variable_defined?(ivar) && instance_variable_get(ivar)
            else
              instance_variable_set(ivar, value)
            end
          end
        end

        define_method(:inherited) do |klass|
          super(klass)
          args.each { |name| klass.send(name, send(name)) }
        end
      end

      extend(mod)
    end
  end
end
