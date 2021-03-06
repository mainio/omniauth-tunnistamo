# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-tunnistamo/version'

Gem::Specification.new do |spec|
  spec.name = 'omniauth-tunnistamo'
  spec.version = OmniAuth::Tunnistamo::VERSION
  spec.required_ruby_version = '>= 2.6'
  spec.authors = ['Antti Hukkanen']
  spec.email = ['antti.hukkanen@mainiotech.fi']

  spec.summary = 'Provides a Tunnistamo strategy for OmniAuth.'
  spec.description = 'Tunnistamo identification service integration for OmniAuth.'
  spec.homepage = 'https://github.com/mainio/omniauth-tunnistamo'
  spec.license = 'MIT'

  spec.files = Dir[
    '{lib}/**/*',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]

  spec.require_paths = ['lib']

  spec.add_dependency 'omniauth_openid_connect', '~> 0.3', '>= 0.3.5'

  # Basic development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'

  # Testing the requests
  spec.add_development_dependency 'rack-test', '~> 1.1.0'
  spec.add_development_dependency 'webmock', '~> 3.12'
  spec.add_development_dependency 'xmlenc', '~> 0.7.1'

  # Code coverage
  spec.add_development_dependency 'simplecov', '~> 0.21.2'

  # Code styling
  spec.add_development_dependency 'rubocop', '~> 1.14.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.3.0'
end
