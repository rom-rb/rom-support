require 'logger'

module ROM
  module Deprecations
    # @api private
    def deprecate(old_name, new_name, msg = nil)
      class_eval do
        define_method(old_name) do |*args, &block|
          ROM::Deprecations.announce "#{self.class}##{old_name} is", <<-MSG
            Please use #{self.class}##{new_name} instead.
            #{msg}
          MSG
          __send__(new_name, *args, &block)
        end
      end
    end

    def deprecate_class_method(old_name, new_name, msg = nil)
      full_msg =
        if new_name.is_a?(Symbol)
          full_msg = Deprecations.deprecation_message "#{self.name}.#{old_name}", <<-MSG
          Please use #{self.name}.#{new_name} instead.
          #{msg}
          MSG
        else
          Deprecations.deprecation_message "#{self.name}.#{old_name}", new_name
        end

      meth = new_name.is_a?(Symbol) ? method(new_name) : method(old_name)
      instance_eval "undef #{old_name}"

      class_eval do
        define_singleton_method(old_name) do |*args, &block|
          Deprecations.warn(full_msg)
          meth.call(*args, &block)
        end
      end
    end

    def self.warn(msg)
      logger.warn(msg.gsub(/^\s+/, ''))
    end

    def self.announce(name, msg)
      warn(deprecation_message(name, msg))
    end

    def self.deprecation_message(name, msg)
      <<-MSG
        #{name} is deprecated and will be removed in the next major version
        #{message(msg)}
      MSG
    end

    def self.message(msg)
      <<-MSG
        #{msg}
        #{caller.detect { |l| !l.include?('lib/rom')}}
      MSG
    end

    def self.logger(output = nil)
      if defined?(@logger)
        @logger
      else
        set_logger!(output)
      end
    end

    def self.set_logger!(output = nil)
      @logger = Logger.new(output || $stdout)
      @logger.formatter = proc { |severity, datetime, progname, msg|
        "[rom] #{msg.dump}\n"
      }
      @logger
    end
  end
end
