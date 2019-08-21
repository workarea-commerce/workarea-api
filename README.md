# Workarea API

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

To begin using the Workarea API, add the following to your **Gemfile** in
the https://gems.weblinc.com `source` block:

```ruby
source 'https://gems.weblinc.com' do
  # ... all your other unquestionably fantastic Workarea gems ...
  gem 'weblinc-api'
end
```

Next, mount the API engines into **config/routes.rb**.

You can either use a path prefix:

```ruby
Rails.application.routes.draw do
  # ...all your other absolutely fabulous Workarea routes...
  mount Workarea::Api::Engine => '/api', as: :api
  # ...except this one. make sure it's last.
  mount Workarea::Storefront::Engine => '/', as: :storefront
end
```

Or, a subdomain. To use a subdomain for your API, create a file at
**app/routing_constraints/api_subdomain_constraint.rb** with the
following contents:

```ruby
class ApiSubdomainConstraint
  def self.matches?(request)
    request.subdomain =~ /^api/
  end
end
```

Then, wrap your `mount` statement with a `constraints` block:

```ruby
constraints ApiSubdomainConstraint do
  mount Workarea::Api::Engine => '/', as: :api
end
```

That will allow clients to access your API at https://api.yourtotallyamazingstore.com

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

## Copyright & Licensing

Copyright WebLinc 2017-2019. All rights reserved.

For licensing, contact [sales@workarea.com][]

[Admin API]: https://plugins.workarea.com/plugins/api-admin
[Storefront API]: https://plugins.workarea.com/plugins/api-storefront
[documentation tests]: https://stash.tools.weblinc.com/projects/WL/repos/workarea-api/browse/test/documentation/workarea/api
[sales@workarea.com]: mailto:sales@workarea.com
