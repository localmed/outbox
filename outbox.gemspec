# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'outbox/version'

Gem::Specification.new do |spec|
  spec.name          = 'outbox'
  spec.version       = Outbox::VERSION
  spec.authors       = ['Pete Browne']
  spec.email         = ['pete.browne@localmed.com']
  spec.description   = %q{A generic interface for sending email, SMS, & push notifications.}
  spec.summary       = %q{Outbox is a generic interface for sending notifications using a variety of protocols, with built-in support for the most popular SaaS solutions.}
  spec.homepage      = 'https://github.com/localmed/outbox'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
end
