# OmniAuth Tunnistamo (OpenID Connect)

This is an unofficial OmniAuth strategy for authenticating with the Tunnistamo
identity provider used by cities such as Helsinki and Turku. This gem is mostly
a configuration wrapper around
[`omniauth_openid_connect-saml`](https://github.com/m0n9oose/omniauth_openid_connect)
which uses [`openid_connect`](https://github.com/nov/openid_connect) for OpenID
Connect authentication implementation with identity providers, such as
Tunnistamo.

The gem can be used to hook Ruby/Rails applications to the Tunnistamo
identification service.

The gem has been developed by [Mainio Tech](https://www.mainiotech.fi/).

The development has been sponsored by the
[City of Turku](https://www.turku.fi/) and the
[City of Helsinki](https://www.hel.fi/).

The Tunnistamo service is originally developed by the City of Helsinki and it
has been taken into use in other cities as well. You can find the original
source code from:
https://github.com/City-of-Helsinki/tunnistamo

## Preparation

In order to start using the Tunnistamo authentication endpoints, you will need
to ask the Tunnistamo administrator to create an application in Tunnistamo
with the callback URLs of your own service. Please contact the Tunnistamo
administrator for further information or read through the Tunnistamo
documentation.

The details that you need to send to the Tunnistamo administrator are similar to
the following information (apply to your service's domain) for
non-Rails+Devise applications:

- Your application's name: Decidim for City
- Callback URL: https://www.service.fi/auth/tunnistamo/callback

### Rails and Devise

When applying this gem to Rails and Devise, the URLs can also include a path
prefix to separate the scope of the authentication requests. For example, if
you are using a `:user` scope with Devise, the callback URL would look like
following:

https://www.service.fi/users/auth/tunnistamo/callback

## Installation and Configuration

This gem has been only tested and used with Rails applications using Devise, so
this installation guide only covers that part. In case you are interested to
learn how you can use this with other frameworks, please refer to the
[`omniauth_openid_connect-saml`](https://github.com/m0n9oose/omniauth_openid_connect)
documentation and apply it to your needs (changing the strategy name to
`:tunnistamo` and strategy class to `OmniAuth::Strategies::Tunnistamo`).

To install this gem, add the following to your Gemfile:

```ruby
gem 'omniauth-tunnistamo'
```

For configuring the strategy for Devise, add the following in your
`config/initializers/devise.rb` file:

```ruby
Devise.setup do |config|
  config.omniauth :tunnistamo,
    issuer: "https://tunnistamo.service.fi/openid",
    client_options: {
      port: 443,
      scheme: "https",
      host: "tunnistamo.service.fi",
      identifier: "client-id-for-tunnistamo-from-their-admin",
      secret: "client-secret-for-tunnistamo-from-their-admin",
      redirect_uri: "https://www.service.fi/users/auth/tunnistamo/callback"
    },
    post_logout_redirect_uri: "https://www.service.fi"
end
```

## Identification Responses

The user's data is transmitted from Tunnistamo in the OpenID Connect
authentication response. This data will be available in the OmniAuth
[extra hash](https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema#schema-10-and-later).

In order to access the response data, you can fetch the OmniAuth extra has and
the corresponding user data in the OmniAuth callback handler, e.g. in Rails
Devise controllers as follows:

```ruby
def raw_info
  raw_hash = request.env["omniauth.auth"]
  extra_hash = raw_hash[:extra]

  extra_hash[:raw_info]
end
```

### Personal Information Transmitted From Tunnistamo

The user's personal information transmitted from Tunnistamo can be found under
the `:raw_info` key in the OmniAuth extra hash described above.

This attributes hash will contain the keys described by the Tunnistamo
documentation or administrator. The information is limited to the underlying
authentication service and what kind of data it provides.

If you need more information about this data, contact the Tunnistamo
administrator.

## License

MIT, see [LICENSE](LICENSE).
