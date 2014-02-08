# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'neighborly/balanced/creditcard/version'

Gem::Specification.new do |spec|
  spec.name          = 'neighborly-balanced-creditcard'
  spec.version       = Neighborly::Balanced::Creditcard::VERSION
  spec.authors       = ['Josemar Luedke', 'Irio Musskopf']
  spec.email         = %w(josemarluedke@gmail.com iirineu@gmail.com)
  spec.summary       = 'Neighbor.ly integration with Credit Card Balanced Payments.'
  spec.description   = 'Neighbor.ly integration with Credit Card Balanced Payments.'
  spec.homepage      = 'https://github.com/neighborly/neighborly-balanced-creditcard'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'neighborly-balanced', '~> 0'

  spec.add_development_dependency 'bundler',     '~> 1.4'
  spec.add_development_dependency 'rake',        '~> 0'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rspec-rails'
end
