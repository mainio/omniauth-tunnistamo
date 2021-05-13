# frozen_string_literal: true

require 'spec_helper'

# The underlying OpenIDConnect stategy should already handle and test most of
# the OpenID connect specific functionality. The aim of this test is to test the
# Tunnistamo specific functionality within that strategy and the Tunnistamo
# custom strategy methods. This should ensure our customizations and the basic
# flows also work when the underling strategy is changed.
describe OmniAuth::Strategies::Tunnistamo, type: :strategy do
  include OmniAuth::Test::StrategyTestCase

  let(:auth_hash) { last_request.env['omniauth.auth'] }
  let(:strategy_options) do
    {
      issuer: "#{auth_server_uri}/openid",
      client_options: {
        port: auth_server_uri_secured ? 443 : 80,
        scheme: auth_server_uri_secured ? 'https' : 'http',
        host: 'tunnistamo.test.fi',
        identifier: client_id,
        secret: client_secret,
        redirect_uri: 'https://www.service.fi/auth/tunnistamo/callback'
      },
      post_logout_redirect_uri: 'https://www.service.fi'
    }
  end
  let(:auth_server_uri) { 'https://tunnistamo.test.fi' }
  let(:auth_server_uri_secured) { auth_server_uri =~ %r{^https://} }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'client_secret' }
  let(:strategy) { [OmniAuth::Strategies::Tunnistamo, strategy_options] }

  before do
    # Stub the openid configuration to return the locally stored metadata for
    # easier testing. Otherwise an external HTTP request would be made when the
    # OmniAuth strategy is configured AND there would need to be a Tunnistamo
    # authentication server always running at that URL.
    configuration_file =
      if auth_server_uri_secured
        'openid_configuration_secured'
      else
        'openid_configuration'
      end
    stub_request(
      :get,
      "#{auth_server_uri}/openid/.well-known/openid-configuration"
    ).to_return(status: 200, body: File.new(
      support_filepath(configuration_file)
    ), headers: {})
  end

  describe 'GET /auth/tunnistamo' do
    subject { get '/auth/tunnistamo' }

    it 'should apply the local options' do
      is_expected.to be_redirect
      expect(subject.location).to match(%r{^#{auth_server_uri}/openid/authorize\?client_id=#{client_id}&nonce=\w{32}&redirect_uri=https%3A%2F%2Fwww.service.fi%2Fauth%2Ftunnistamo%2Fcallback&response_type=code&scope=openid%20email%20profile&state=\w{32}&ui_locales=en$})

      instance = last_request.env['omniauth.strategy']

      expect(instance.options[:name]).to eq(:tunnistamo)
      expect(instance.options[:discovery]).to be(true)
      expect(instance.options[:scope]).to eq(%i[openid email profile])

      expect(instance.options[:client_options]).to include(
        'identifier' => client_id,
        'secret' => client_secret,
        'scheme' => 'https',
        'host' => 'tunnistamo.test.fi',
        'port' => 443,
        'redirect_uri' => 'https://www.service.fi/auth/tunnistamo/callback',
        'authorization_endpoint' => 'https://tunnistamo.test.fi/openid/authorize',
        'token_endpoint' => 'https://tunnistamo.test.fi/openid/token',
        'userinfo_endpoint' => 'https://tunnistamo.test.fi/openid/userinfo',
        'end_session_endpoint' => 'https://tunnistamo.test.fi/openid/end-session',
        'jwks_uri' => 'https://tunnistamo.test.fi/openid/jwks'
      )
    end

    context 'with insecure server URI' do
      let(:auth_server_uri) { 'http://tunnistamo.test.fi' }

      it 'should hit the production metadata URL' do
        is_expected.to be_redirect
        expect(subject.location).to match(%r{^#{auth_server_uri}/openid/authorize\?client_id=#{client_id}&nonce=\w{32}&redirect_uri=https%3A%2F%2Fwww.service.fi%2Fauth%2Ftunnistamo%2Fcallback&response_type=code&scope=openid%20email%20profile&state=\w{32}&ui_locales=en$})

        instance = last_request.env['omniauth.strategy']

        expect(instance.options[:name]).to eq(:tunnistamo)
        expect(instance.options[:discovery]).to be(true)
        expect(instance.options[:scope]).to eq(%i[openid email profile])

        expect(instance.options[:client_options]).to include(
          'identifier' => client_id,
          'secret' => client_secret,
          'scheme' => 'http',
          'host' => 'tunnistamo.test.fi',
          'port' => 80,
          'redirect_uri' => 'https://www.service.fi/auth/tunnistamo/callback',
          'authorization_endpoint' => 'http://tunnistamo.test.fi/openid/authorize',
          'token_endpoint' => 'http://tunnistamo.test.fi/openid/token',
          'userinfo_endpoint' => 'http://tunnistamo.test.fi/openid/userinfo',
          'end_session_endpoint' => 'http://tunnistamo.test.fi/openid/end-session',
          'jwks_uri' => 'http://tunnistamo.test.fi/openid/jwks'
        )
      end
    end

    context 'with lang parameter' do
      let(:lang_parameter) { 'locale' }

      shared_examples 'lang added' do |request_locale, expected_locale|
        subject { get "/auth/tunnistamo?#{lang_parameter}=#{request_locale}" }

        it do
          is_expected.to be_redirect

          location = URI.parse(last_response.location)
          if expected_locale.nil?
            expect(location.query).not_to match(/&ui_locales=#{request_locale}/)
          else
            expect(location.query).to match(/&ui_locales=#{expected_locale}/)
          end
        end
      end

      context 'when set to fi' do
        it_behaves_like 'lang added', 'fi', 'fi'
      end

      context 'when set to fi-FI' do
        it_behaves_like 'lang added', 'fi-FI', 'fi'
      end

      context 'when set to sv' do
        it_behaves_like 'lang added', 'sv', 'sv'
      end

      context 'when set to sv_SE' do
        it_behaves_like 'lang added', 'sv_SE', 'sv'
      end

      context 'when set to en_GB' do
        it_behaves_like 'lang added', 'en_GB', 'en'
      end

      context 'when set to en-US' do
        it_behaves_like 'lang added', 'en-US', 'en'
      end

      context 'when set to et' do
        it_behaves_like 'lang added', 'et', nil
      end

      context 'when set to de-DE' do
        it_behaves_like 'lang added', 'de-DE', nil
      end

      context 'when set to nb_NO' do
        it_behaves_like 'lang added', 'nb_NO', nil
      end

      context 'with lang parameter set to "language"' do
        let(:lang_parameter) { 'language' }

        it_behaves_like 'lang added', 'fi', 'fi'
      end

      context 'with lang parameter set to "lang"' do
        let(:lang_parameter) { 'lang' }

        it_behaves_like 'lang added', 'fi', 'fi'
      end
    end
  end

  describe 'POST /auth/tunnistamo/callback' do
    let(:code) { SecureRandom.hex(16) }
    let(:state) { SecureRandom.hex(16) }
    let(:nonce) { SecureRandom.hex(16) }
    let(:sub) { '248289761001' }
    let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
    let(:public_key) { private_key.public_key }
    let(:access_token) { 'test_access_token' }
    let(:now) { Time.now.to_i }
    let(:id_token) do
      ::OpenIDConnect::ResponseObject::IdToken.new(
        iss: 'https://tunnistamo.test.fi/openid',
        sub: sub,
        aud: client_id,
        nonce: nonce,
        exp: now + 1000,
        iat: now
      )
    end

    before do
      get '/'
      session['omniauth.state'] = state
      session['omniauth.nonce'] = nonce

      keypair = OpenSSL::PKey::RSA.new(2048)
      jwk = JSON::JWK.new(keypair)
      algorithm = 'RS256'

      access_token_json = {
        access_token: access_token,
        id_token: id_token.to_jwt(jwk, algorithm),
        token_type: 'Bearer'
      }

      stub_request(
        :post,
        "#{auth_server_uri}/openid/token"
      ).with(
        body: {
          'client_id' => client_id,
          'client_secret' => client_secret,
          'code' => code,
          'grant_type' => 'authorization_code',
          'redirect_uri' => 'https://www.service.fi/auth/tunnistamo/callback',
          'scope' => 'openid email profile'
        }
      ).to_return(
        status: 200,
        body: JSON.generate(access_token_json),
        headers: {'Content-Type' => 'application/json'}
      )

      stub_request(
        :get,
        "#{auth_server_uri}/openid/jwks"
      ).to_return(
        status: 200,
        body: JSON.generate(
          {
            keys: [
              jwk.normalize.merge(kid: jwk[:kid], alg: algorithm, use: 'sig')
            ]
          }
        ),
        headers: {'Content-Type' => 'application/json'}
      )

      userinfo_json = {
        sub: sub,
        preferred_username: 'Johnny',
        first_name: 'John Jimmy',
        given_name: 'John',
        middle_name: 'Jimmy',
        family_name: 'Doe',
        email: 'john.doe@foo.bar',
        birthdate: '1975-12-31',
        gender: 'male'
      }

      stub_request(
        :get,
        "#{auth_server_uri}/openid/userinfo"
      ).with(
        headers: {'Authorization' => "Bearer #{access_token}"}
      ).to_return(
        status: 200,
        body: JSON.generate(userinfo_json),
        headers: {'Content-Type' => 'application/json'}
      )

      # Finally, request the callback when the stubs are in place
      get(
        '/auth/tunnistamo/callback',
        code: code,
        state: state,
        id_token: id_token.to_jwt(private_key)
      )
    end

    it do
      auth = last_request.env['omniauth.auth']

      expect(auth[:info][:email]).to eq('john.doe@foo.bar')
      expect(auth[:info][:nickname]).to eq('Johnny')
      expect(auth[:info][:first_name]).to eq('John')
      expect(auth[:info][:last_name]).to eq('Doe')
      expect(auth[:info][:gender]).to eq('male')

      expect(auth[:extra][:raw_info][:birthdate]).to eq('1975-12-31')
    end
  end

  describe 'GET /auth/tunnistamo/logout' do
    subject { get '/auth/tunnistamo/logout' }

    it do
      is_expected.to be_redirect
      expect(subject.location).to match(%r{^#{auth_server_uri}/openid/end-session\?post_logout_redirect_uri=https%3A%2F%2Fwww.service.fi$})
    end
  end
end
