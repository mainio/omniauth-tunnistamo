# frozen_string_literal: true

source 'https://rubygems.org'

group :test do
  gem 'codecov', require: false

  # Test framework
  gem 'rspec', '~> 3.12'

  # Testing the requests
  gem 'rack-test', '~> 2.1.0'
  gem 'webmock', '~> 3.18'
  gem 'xmlenc', '~> 0.8.0'

  # Code coverage
  gem 'simplecov', '~> 0.22.0'
end

group :development, :test do
  # Basic development dependencies
  gem 'rake', '~> 13.0'

  # Code styling
  gem 'rubocop', '~> 1.54.1'
  gem 'rubocop-rake', '~> 0.6.0'
  gem 'rubocop-rspec', '~> 2.22.0'
end

gemspec
