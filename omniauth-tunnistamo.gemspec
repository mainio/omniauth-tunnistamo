# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-tunnistamo/version'

Gem::Specification.new do |spec|
  spec.name = 'omniauth-tunnistamo'
  spec.version = OmniAuth::Tunnistamo::VERSION
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
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'

  # Testing the requests
  spec.add_development_dependency 'rack-test', '~> 1.1.0'
  spec.add_development_dependency 'webmock', '~> 3.6', '>= 3.6.2'
  spec.add_development_dependency 'xmlenc', '~> 0.7.1'

  # Code coverage
  spec.add_development_dependency 'simplecov', '~> 0.16.0'
end
