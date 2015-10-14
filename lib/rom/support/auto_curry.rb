require 'byebug'

module ROM
  module AutoCurry
    def self.extended(klass)
      klass.define_singleton_method(:method_added) do |name|
        return if auto_curry_busy?
        auto_curry_guard { auto_curry(name) }
        super(name)
      end
    end

    def auto_curry_guard
      @__auto_curry_busy__ = true
      yield
    ensure
      @__auto_curry_busy__ = false
    end

    def auto_curry_busy?
      @__auto_curry_busy__ ||= false
    end

    def auto_curry(name, &block)
      curried = self.curried
      meth = instance_method(name)
      arity = meth.arity

      define_method(name) do |*args|
        response =
          if arity < 0 || arity == args.size
            meth.bind(self).(*args)
          else
            curried.new(self, name: name, curry_args: args, arity: arity)
          end

        if block
          response.instance_exec(&block)
        else
          response
        end
      end
    end
  end
end
