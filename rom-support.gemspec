# encoding: utf-8

require File.expand_path('../lib/rom/support/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rom-support'
  gem.summary       = 'Ruby Object Mapper - Support libraries'
  gem.description   = gem.summary
  gem.author        = 'Piotr Solnica'
  gem.email         = 'piotr.solnica@gmail.com'
  gem.homepage      = 'http://rom-rb.org'
  gem.require_paths = ['lib']
  gem.version       = ROM::Support::VERSION.dup
  gem.files         = `git ls-files`.split("\n").reject { |name| name.include?('benchmarks') }
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  gem.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  gem.add_runtime_dependency 'wisper', '~> 1.6', '>= 1.6.0'
  gem.add_runtime_dependency 'transproc', '~> 0.4.0'

  gem.add_development_dependency 'rake', '~> 10.3'
  gem.add_development_dependency 'rspec', '~> 3.3'
end
