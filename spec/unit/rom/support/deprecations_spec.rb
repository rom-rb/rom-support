require 'rom/support/deprecations'
require 'tempfile'

RSpec.describe ROM::Deprecations do
  let(:log_file) do
    Tempfile.new('rom_deprecations')
  end

  before do
    ROM::Deprecations.set_logger!(log_file)
  end

  let(:output) do
    log_file.close
    log_file.open.read
  end

  describe '.warn' do
    it 'logs a warning message' do
      ROM::Deprecations.warn('hello world')
      expect(output).to include('[rom] hello world')
    end
  end

  describe '.announce' do
    it 'warns about a deprecated method' do
      ROM::Deprecations.announce(:foo, 'hello world')
      expect(output).to include('[rom] foo is deprecated and will be removed')
      expect(output).to include('hello world')
    end
  end

  describe '.deprecate_class_method' do
    subject(:klass) do
      Class.new do
        extend ROM::Deprecations

        def self.name
          "Test"
        end

        def self.log(msg)
          "log: #{msg}"
        end

        def self.hello(word)
          "hello #{word}"
        end
        deprecate_class_method :hello, "is no more"

        def self.logging(msg)
          "logging: #{msg}"
        end
        deprecate_class_method :logging, :log
      end
    end

    it 'deprecates method that is to be removed' do
      res = klass.hello("world")

      expect(res).to eql("hello world")
      expect(output).to include('[rom] Test.hello is deprecated and will be removed')
      expect(output).to include('is no more')
    end

    it 'deprecates a method in favor of another' do
      res = klass.logging('foo')

      expect(res).to eql('log: foo')
      expect(output).to include('[rom] Test.logging is deprecated and will be removed')
    end
  end
end
