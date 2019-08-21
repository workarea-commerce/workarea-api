# Workarea Admin API

Part of the [Workarea API][], the Admin API is used for programmatic
access to your Workarea application's data model. It's designed to be
"auto-extending", so that when you add or change fields in your Workarea
models, those fields will be available for use in the API. This part of
the Workarea API is primarily used for external services integration,
such as with order management systems, enterprise resource planners, or
email service providers, and provides detailed order and shipping information
to such systems.

## Overview

- [Swagger][] integration with an implementation of the API in [OAS 2.0][OpenAPI]
- Basic CRUD actions for core Workarea models
- Bulk "Upsert" functionality for importing multiple records in the same
  HTTP `PATCH` request.

## Getting Started

To use this plugin, install the **workarea-api** gem.

For more information on the API as a whole, and to learn how to set up
the API plugin, consult the [main README][Workarea API].

## Authentication

The Admin API secures itself using basic HTTP authentication. It authenticates
with the same email address and password used to login to the admin. You will
also need the API access permissions enabled for your account. This can be done
in the permissions tab of the user edit page in the admin. You can also do this
in the Rails console by enabling the `api_access` field on the user:

To make requests to the Admin API, ensure your user has API access
permissions. This can be changed in the "Permissions" tab of the "Edit
User" page in the admin, or within the `rails console` using the
following code:

```ruby
Workarea::User.find_by_email('user@workarea.com').update!(api_access: true)
```

(**NOTE:** Super-admins will automatically have this access)

The Admin API uses [HTTP Basic Authentication][] to authorize client
requests, with the format `email:password`. You can provide these
details in an `Authorization` header, encoded in Base64...

```http
Authorization: Basic eW91cnVzZXJAZXhhbXBsZS5jb206UGFzc3dvcmQhMQ==\n
```

Or, in the URL, with requests made like:

https://youruser@example.com:Password!1@yourtotallyamazingstore.com/api/orders.json

Unlike the Storefront API, all Admin API endpoints are protected behind
authentication.

## Swagger

Workarea's Admin API implements the [OpenAPI][] Specification for
integration with [Swagger][] tools, IPaaS solutions like [Cenit][] or
[Boomi][], and anything else that speaks OpenAPI. This can be accessed
at your API's `/api/admin/swagger.json` endpoint, for example
https://youruser@example.com:Password!1@yourtotallyamazingstore.com/api/swagger.json.
Point your Swagger client to this endpoint to be able to use and browse
the Swagger documentation for our API.

## Copyright & Licensing

Copyright Workarea 2017-2019. All rights reserved.

For licensing, contact [sales@workarea.com][].

[Workarea API]: https://plugins.workarea.com/plugins/api
[sales@workarea.com]: mailto:sales@workarea.com
[HTTP Basic Authentication]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#Basic_authentication_scheme
[OpenAPI]: https://swagger.io/resources/open-api/
[Swagger]: https://swagger.io
[Cenit]: https://cenit.io
[Boomi]: https://boomi.com
