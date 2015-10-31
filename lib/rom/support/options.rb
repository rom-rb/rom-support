module ROM
  # Helper module for classes with a constructor accepting option hash
  #
  # This allows us to DRY up code as option hash is a very common pattern used
  # across the codebase. It is an internal implementation detail not meant to
  # be used outside of ROM
  #
  # @example
  #   class User
  #     include Options
  #
  #     option :name, type: String, reader: true
  #     option :admin, allow: [true, false], reader: true, default: false
  #
  #     def initialize(options={})
  #       super
  #     end
  #   end
  #
  #   user = User.new(name: 'Piotr')
  #   user.name # => "Piotr"
  #   user.admin # => false
  #
  # @api public
  module Options
    InvalidOptionValueError = Class.new(StandardError)
    InvalidOptionKeyError = Class.new(StandardError)

    # @return [Hash<Option>] Option definitions
    #
    # @api public
    attr_reader :options

    def self.included(klass)
      klass.extend ClassMethods
      klass.option_definitions = Definitions.new
    end

    # Defines a single option
    #
    # @api private
    class Option
      attr_reader :name, :reader

      def initialize(name, options = {})
        @name   = name
        @reader = options.fetch(:reader) { false }
        # Prepares transformations applied by [#transform]
        add_coercer options[:coercer]
        add_default options[:default] if options.key? :default
        add_type_checker options[:type]
        add_value_checker options[:allow]
        add_reader if reader
      end

      # Takes options of some object, applies current transformations
      # and returns updated options
      #
      # @param [Object] object
      # @param [Hash] options
      #
      # @return [Hash] options
      #
      def transform(object, options)
        transformers.inject(options) { |a, e| e[object, a] }
      end

      private

      def transformers
        @transformers ||= []
      end

      def add_reader
        transformers << Transformers[:reader_assigner, name]
      end

      def add_default(value)
        transformer = value.respond_to?(:call) ? :default_proc : :default_value
        transformers << Transformers[transformer, name, value]
      end

      def add_coercer(fn)
        return unless fn.is_a?(Proc)
        transformers << Transformers[:coercer, name, fn]
      end

      def add_type_checker(type)
        return unless type.is_a?(Class)
        transformers << Transformers[:type_checker, name, type]
      end

      def add_value_checker(values)
        return unless values.respond_to?(:include?)
        transformers << Transformers[:value_checker, name, values]
      end
    end

    # Manage all available options
    #
    # @api private
    class Definitions
      def initialize
        @options = {}
      end

      def initialize_copy(source)
        super
        @options = @options.dup
      end

      def define(option)
        @options[option.name] = option
      end

      def process(object, options)
        ensure_known_options(options)
        each { |_, option| options.update option.transform(object, options) }
      end

      def names
        @options.keys
      end

      private

      def each(&block)
        @options.each(&block)
      end

      def ensure_known_options(options)
        options.each_key do |name|
          @options.fetch(name) do
            fail InvalidOptionKeyError, "#{name.inspect} is not a valid option"
          end
        end
      end
    end

    # @api private
    module ClassMethods
      # Available options
      #
      # @return [Definitions]
      #
      # @api private
      attr_accessor :option_definitions

      # Defines an option
      #
      # @param [Symbol] name option name
      #
      # @param [Hash] settings option settings
      # @option settings [Class] :type Restrict option type. Default: +Object+
      # @option settings [Boolean] :reader Define a reader? Default: +false+
      # @option settings [Array] :allow Allow certain values. Default: Allow anything
      # @option settings [Object] :default Set default value for missing option
      # @option settings [Proc] :coercer Set coercer for assigned option
      #
      # @api public
      def option(name, settings = {})
        option = Option.new(name, settings)
        option_definitions.define(option)
        attr_reader(name) if option.reader
      end

      # @api private
      def inherited(descendant)
        descendant.option_definitions = option_definitions.dup
        super
      end
    end

    # Initialize options provided as optional last argument hash
    #
    # @example
    #   class Commands
    #     include Options
    #
    #     # ...
    #
    #     def initialize(relations, options={})
    #       @relation = relation
    #       super
    #     end
    #   end
    #
    # @param [Array] args
    def initialize(*args)
      options = args.last ? args.last.dup : {}
      self.class.option_definitions.process(self, options)
      @options = options.freeze
    end

    # Collection of transformers for options
    #
    module Transformers
      extend Transproc::Registry

      import :identity, from: Transproc::Coercions

      def self.default_value(_, options, name, value)
        return options if options.key?(name)
        options.merge(name => value)
      end

      def self.default_proc(object, options, name, fn)
        return options if options.key?(name)
        options.merge(name => fn.call(object))
      end

      def self.coercer(_, options, name, fn)
        return options unless options.key?(name)
        value = options[name]
        options.merge name => fn[value]
      end

      def self.type_checker(_, options, name, type)
        return options unless options.key?(name)
        value = options[name]

        return options if options[name].is_a?(type)
        fail(
          InvalidOptionValueError,
          "#{name.inspect}:#{value.inspect} has incorrect type" \
          " (#{type} is expected)"
        )
      end

      def self.value_checker(_, options, name, list)
        return options unless options.key?(name)
        value = options[name]

        return options if list.include?(options[name])
        fail(
          InvalidOptionValueError,
          "#{name.inspect}:#{value.inspect} has incorrect value."
        )
      end

      def self.reader_assigner(object, options, name)
        object.instance_variable_set(:"@#{name}", options[name])
        options
      end
    end
  end
end
