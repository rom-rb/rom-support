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
      expect(output).to include('[rom] "hello world"')
    end
  end

  describe '.announce' do
    it 'warns about a deprecated method' do
      ROM::Deprecations.announce(:foo, 'hello world')
      expect(output).to include('[rom] "foo is deprecated and will be removed')
      expect(output).to include('hello world')
    end
  end
end
