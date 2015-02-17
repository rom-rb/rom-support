module ROM
  # Helper module providing thin interface around an inflection backend.
  #
  # @private
  module Inflector
    def self.setup
      @inflector =
        begin
          require 'active_support/inflector'
          ::ActiveSupport::Inflector
        rescue LoadError
          require 'inflecto'
          ::Inflecto
        end
    rescue LoadError
      raise LoadError,
            "No inflector library could be found: "\
            "please install either the `activesupport` or `inflecto` gem."
    end
    setup

    def self.camelize(input)
      @inflector.camelize(input)
    end

    def self.underscore(input)
      @inflector.underscore(input)
    end

    def self.singularize(input)
      @inflector.singularize(input)
    end

    def self.pluralize(input)
      @inflector.pluralize(input)
    end

    def self.demodulize(input)
      @inflector.demodulize(input)
    end

    def self.constantize(input)
      @inflector.constantize(input)
    end

    def self.classify(input)
      @inflector.classify(input)
    end
  end
end
