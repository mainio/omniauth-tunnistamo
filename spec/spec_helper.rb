# frozen_string_literal: true

require 'simplecov' if ENV['SIMPLECOV'] || ENV['CODECOV']
if ENV['CODECOV']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'omniauth-tunnistamo'
require 'webmock/rspec'
require 'rack/test'
require 'rexml/document'
require 'rexml/xpath'
require 'base64'

TEST_LOGGER = Logger.new(StringIO.new)
OmniAuth.config.logger = TEST_LOGGER
OmniAuth.config.request_validation_phase = proc {}
OmniAuth.config.full_host = 'https://www.service.fi'

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: 'acme-v02.api.letsencrypt.org'
)

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def support_filepath(filename)
  File.expand_path(File.join('..', 'support', filename), __FILE__)
end

def support_file_io(filename)
  IO.read(support_filepath(filename))
end
