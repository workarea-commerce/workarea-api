# Workarea API
[![CI Status](https://github.com/workarea-commerce/workarea-api/workflows/CI/badge.svg)](https://github.com/workarea-commerce/workarea-api/actions)

**workarea-api** defines an HTTP API, using JSON as a data format, for
programmatic access to your Workarea application. The Workarea API is
used for many purposes, such as integration with external services, or
providing an alternative user interface to your web store (like an
on-premises kiosk or mobile application). As such, Workarea provides two
separate APIs for different purposes:

- The [Admin API][] is only available to admin users with the necessary
  "API Access" permissions, and provides CRUD operations on all data models
  in the application. It's primarily used for integration with external
  service providers, such as an OMS or ERP.
- The [Storefront API][] has a slightly more complex authentication
  scheme, because it's used by end-users to browse and purchase items on
  the storefront. This API is suitable for building alternative user
  interfaces to Workarea

## Getting Started

To begin using the Workarea API, add the following to your **Gemfile**:

```ruby
gem 'weblinc-api'
```

Next, mount the API engines into **config/routes.rb**:

```ruby
Rails.application.routes.draw do
  mount_workarea_api at: '/api'
end
```

You'll be able to access the API at https://yourtotallyamazingstore.com/api

To use a subdomain for your API, configure your routes like so:

```ruby
Rails.application.routes.draw do
  mount_workarea_api subdomain: 'api'
end
```

This will allow access to your API at https://api.yourtotallyamazingstore.com

When using routing constraints for the API, all test cases that use the

## Configuration

This plugin provides a number of options for configuring its usage...

- **config.api_product_image_jobs_blacklist** configures the Dragonfly
  processor jobs whose URLs are omitted from image JSON responses in the
  Storefront API. Default is `:convert`, `:encode`, `:rotate`, `:optim`,
  `:avatar`, and `:thumb`.
- **config.authentication_token_expiration** sets how long Storefront API auth
  tokens last before they are expired. Default is `1.week`
- **config.max_api_bulk_data_size** configures the max amount of items which
  may be included in a `Workarea::Api::Admin::BulkUpsert`
- **config.api_admin_ignore_definitions** prevents certain models from
  being considered when Swagger JSON is being generated

## Documentation

Documentation for API endpoints is available wherever the
`Workarea::Api::Engine` has been mounted, at the relative path `/docs`.
By default, this path is `/api/docs`. This documentation is loaded from
the gem source by default, but if you customize API endpoints, you'll
need to generate customized documentation with the following command:

```bash
GENERATE_API_DOCS=true bin/rails workarea:test
```

Documentation for the API is built using [documentation tests][], which
describe how each controller and action is to be documented. Look in the
aforementioned link to see some examples of documentation built using
the documentation tests.

License
--------------------------------------------------------------------------------
Workarea Commerce Platform is released under the [Business Software License](https://github.com/workarea-commerce/workarea/blob/master/LICENSE)

[Admin API]: https://github.com/workarea-commerce/workarea-api/tree/master/admin
[Storefront API]: https://github.com/workarea-commerce/workarea-api/tree/master/storefront
[documentation tests]: https://github.com/workarea-commerce/workarea-api/blob/master/storefront/test/documentation/workarea/api/storefront/products_documentation_test.rb
