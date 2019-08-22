# Workarea Storefront API

Part of the [Workarea API][], the Storefront API provides programmatic
access to operations and resources to alternative user interfaces to
your Workarea application, like on-premises kiosks, mobile applications,
and client-side storefront implementations.

## Getting Started

To use this plugin, install the **workarea-api** gem.

For more information on the API as a whole, and to learn how to set up
the API plugin, consult the [main README][Workarea API].

## Authenticating

The Storefront API requires the use of a temporary authentication token,
analogous to the user ID in the session, which tells the backend of
Workarea whether a User is authenticated. It uses the
`Workarea::UrlToken` mixin from core to generate this token.

To obtain an authentication token, make a POST request like so:

```bash
curl \
  --request POST \
  --data '{ "email": "your@email.address", "password": "Password1!" }' \
  "http://yourincredibleheadlesscommercesolution.biz/api/authentication_tokens.json"
```

You should get a response that looks like this:

```json
{
  "token": "tL6Scp6ubsufq76FZHLbhLWs",
  "expires_at": "2018-12-25T11:58:43.674-05:00"
}
```

Use the `token` in this response to make further authenticated requests
to the API:


```bash
curl \
  --request GET \
  --header 'Authorization: Token token="tL6Scp6ubsufq76FZHLbhLWs"' \
  "http://yourincredibleheadlesscommercesolution.biz/api/carts.json"
```

License
--------------------------------------------------------------------------------
Workarea Commerce Platform is released under the [Business Software License](https://github.com/workarea-commerce/workarea/blob/master/LICENSE)

[Workarea API]: https://github.com/workarea-commerce/workarea-api
