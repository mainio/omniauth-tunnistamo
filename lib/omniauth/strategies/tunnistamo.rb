# frozen_string_literal: true

require 'omniauth_openid_connect'

module OmniAuth
  module Strategies
    class Tunnistamo < OpenIDConnect
      option :name, :tunnistamo
      option :discovery, true
      option :scope, %i[openid email profile]

      # Defines the lang parameters to check from the request phase request
      # parameters. A valid language will be added to the IdP sign in redirect
      # URL as the last parameter (with the name `lang` as expected by
      # Tunnistamo).
      #
      # Tunnistamo generally accepts `fi`, `sv` or `en` in this parameter but it
      # can depend on the underlying service. The language can be parsed from
      # the following kind of strings:
      # - fi
      # - sv-SE
      # - fi_FI
      #
      # In case a valid language cannot be parsed from the parameter, the lang
      # parameter will omitted when Tunnistamo will determine the UI language.
      option :lang_params, %w[locale language lang]

      # The omniauth_openid_connect gem relies on the openid_connect which uses
      # a request client inherited from rack-oauth2. This request client does
      # the access token requests to the authentication server and by default
      # it uses HTTP basic authentication. This does not work if the client
      # credentials contain specific characters (such as ":") which is why we
      # define the "other" authentication method when they are included in a
      # normal POST request. There is no `:other` auth method in the client but
      # with an unknown method it goes to the else block which does exactly
      # this. See: https://git.io/JfSD0
      option :client_auth_method, :other

      def config
        # Make sure the SWD discovery requests (generated by the openid_connect
        # gem) will succeed also with the "http" URI scheme, so it does not
        # force the authentication endpoint to be secured (e.g. in development
        # environment).
        orig_url_builder = SWD.url_builder
        SWD.url_builder = URI::HTTP if options.issuer.match?(%r{^http://})

        result = super
        SWD.url_builder = orig_url_builder

        result
      end

      def authorize_uri
        client.redirect_uri = redirect_uri
        opts = {
          response_type: options.response_type,
          scope: options.scope,
          state: new_state,
          login_hint: options.login_hint,
          prompt: options.prompt,
          nonce: (new_nonce if options.send_nonce),
          hd: options.hd
        }

        # Pass the ?lang=xx to Tunnistamo
        # Does not actually have any effect right now but maybe some day...
        lang = language_for_openid_connect
        opts[:ui_locales] = lang if lang

        client.authorization_uri(opts.compact)
      end

      def end_session_uri
        return unless end_session_endpoint_is_valid?

        end_session_uri = URI(client_options.end_session_endpoint)
        end_session_uri.query = encoded_post_logout_query
        end_session_uri.to_s
      end

    private

      def verify_id_token!(id_token)
        session['omniauth-tunnistamo.id_token'] = id_token if id_token

        super
      end

      def encoded_post_logout_query
        # Store the post logout query because it is fetched multiple times and
        # the ID token is deleted during the first time.
        @encoded_post_logout_query ||= begin
          logout_params = {
            id_token_hint: session.delete('omniauth-tunnistamo.id_token'),
            post_logout_redirect_uri: options.post_logout_redirect_uri
          }.compact

          URI.encode_www_form(logout_params)
        end
      end

      # Determines the application language parameter from one of the configured
      # parameters. Only returns if the parameter is set and contains a value
      # accepted by Tunnistamo.
      def application_language_param
        return nil unless options.lang_params.is_a?(Array)

        options.lang_params.each do |param|
          next unless request.params.key?(param.to_s)

          lang = parse_language_value(request.params[param.to_s])
          return param.to_s unless lang.nil?
        end

        nil
      end

      # Determines the correct language for Tunnistamo. Returns the langauge
      # passed through the URL if the language parameter is set and contains a
      # value accepted by Tunnistamo. Otherwise it will try to fetch the locale
      # from the I18n class if that is available and returns a locale accepted
      # by Tunnistamo.
      def language_for_openid_connect
        param = application_language_param
        return parse_language_value(request.params[param.to_s]) if param

        # Default to I18n locale if it is available
        parse_language_value(I18n.locale.to_s) if Object.const_defined?('I18n')
      end

      # Parses a langauge value from the following types of strings:
      # - fi
      # - fi_FI
      # - fi-FI
      #
      # Returns a string containing the language code if Tunnistamo supports
      # that language.
      def parse_language_value(string)
        language = string.sub('_', '-').split('-').first

        language if language =~ /^(fi|sv|en)$/
      end
    end
  end
end
