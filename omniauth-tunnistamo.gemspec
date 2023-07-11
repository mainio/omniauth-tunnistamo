# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-tunnistamo/version'

Gem::Specification.new do |spec|
  spec.name = 'omniauth-tunnistamo'
  spec.version = OmniAuth::Tunnistamo::VERSION
  spec.required_ruby_version = '>= 2.7'
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

  spec.add_dependency 'omniauth_openid_connect', '~> 0.7'
end
