Workarea Api 4.5.5 (2020-08-19)
--------------------------------------------------------------------------------

*   Update documentation


    Ben Crouse



Workarea Api 4.5.4 (2020-08-19)
--------------------------------------------------------------------------------

*   Handle non-persisted recommendation settings

    This uses `find_or_initialize` to match our usage of
    `Recommendation::Settings` elsewhere in the platform.

    Fixes #19
    Ben Crouse

*   Add Documentation Test for Failed Checkout Update

    This documents the scenario in which a checkout update fails to persist,
    and thus the API returns a `422` error to signify its failure. It
    depends on the code changes in workarea-commerce/workarea#481, and thus
    we will need to bump the Workarea version to restrict its upgrade to
    users of v3.5.17 and beyond.

    API-14
    Tom Scott



Workarea Api 4.5.3 (2020-03-26)
--------------------------------------------------------------------------------

*   Update workarea gem dependencies to reflect reality

    Ben Crouse

*   Fix typo

    Tom Scott

*   Remove use of #many? on embedded relationship for Rails 6 upgrade

    Matt Duffy

*   Bump responders dependecy to 3.0.0

    Matt Duffy



Workarea Api 4.5.2 (2020-01-07)
--------------------------------------------------------------------------------

*   Fix Docs Generator Task Name

    The task name `workarea:api:generate_docs` wasn't able to load the
    environment like the rest of the `workarea:test` tasks because it wasn't
    in the correct Rake namespace. This is due to a hack in core that
    configures the Rake environment such that custom Rake tasks for testing
    are possible. Change the task name to `workarea:test:api_docs` to take
    advantage of this hack so the tests will run properly.

    API-4
    Tom Scott

*   Add Rake Task For Generating API Documentation

    The `workarea:api:docs` task will generate all API documentation for all
    plugins without the need to set environment variables. Developers should
    run this task and commit the results in `doc/api` in order to deploy API
    documentation changes to a server.

    API-4
    Tom Scott

*   Fix rakefile

    Curt Howard



Workarea Api 4.5.0 (2019-11-26)
--------------------------------------------------------------------------------

*   Integrate segmentation into the storefront API

    API-3
    Ben Crouse

*   Documentation presentation improvements

    * Alphabetize the navigation
    * Allow markdown for explanations
    Ben Crouse

*   Remove search suggestions from storefront API

    This has moved to a plugin, and will need to be implemented there.
    Ben Crouse

*   Replace Recommendation::UserActivity with Metrics::User

    Fixes Insight-Related Issues from v3.5.x
    Curt Howard

*   Initial commit on master

    Curt Howard



Workarea Api 4.4.3 (2019-07-09)
--------------------------------------------------------------------------------

*   Fix Release task to ensure docs are generated during release

    API-224
    Curt Howard



Workarea Api 4.4.2 (2019-06-11)
--------------------------------------------------------------------------------

*   Restyle API Documentation

    An effort to make it better match the developer documentation site.

    API-221
    Curt Howard



Workarea Api 4.4.1 (2019-04-30)
--------------------------------------------------------------------------------

*   Add api_access to config.permission_fields

    API-220
    Matt Duffy



Workarea Api 4.4.0 (2019-03-13)
--------------------------------------------------------------------------------

*   Require at least Workarea v3.4 for this minor

    API-218
    Ben Crouse

*   Updates for v3.4 insights integration

    Ben Crouse

*   Update for workarea v3.4 compatibility

    API-216
    Matt Duffy

*   Rewrite API READMEs

    This is a full rewrite of all READMEs associated with **workarea-api**.
    These READMEs now include information on how to authenticate with both
    the Admin and Storefront APIs, as well as what the APIs are used for.

    API-213
    Tom Scott



Workarea Api 4.3.1 (2018-09-19)
--------------------------------------------------------------------------------

*   Custom Validation Message For BulkUpsert Data Length

    `Workarea::Api::Admin::BulkUpsert#data` has a max length of 1000, and
    the validation message for the `:data` attribute made it clear that the
    system counts by characters. API users don't think of their requests
    like that, so the validation message has been changed to "has too many
    objects" so that consumers can know what they need to change in order to
    proceed.

    API-210
    Tom Scott



Workarea Api 4.3.0 (2018-08-21)
--------------------------------------------------------------------------------

*   Restrict API doc route mounting to non-production environments

    API-209
    Curt Howard

*   Remove basic auth from /api/docs route

    API-209
    Curt Howard

*   Add swagger to the admin API

    API-208
    Ben Crouse



Workarea Api 4.2.0 (2018-05-24)
--------------------------------------------------------------------------------

*   Add date to raketask

    Curt Howard



Workarea Api 4.2.0.beta.1 (2018-05-24)
--------------------------------------------------------------------------------

*   Fix test that had inconsisten ordering of results

    Matt Duffy

*   Leverage Workarea Changelog task

    ECOMMERCE-5355
    Curt Howard

*   Allow orders to be filtered by the date they were placed

    API-204
    Curt Howard



Workarea Api 4.1.0 (2018-02-06)
--------------------------------------------------------------------------------

*   Generate documentation as part of release task

    In the release task, run `bin/rails test` with `GENERATE_API_DOCS` set
    to true in order to build docs, then upload docs to Git.

    API-119
    Tom Scott

*   Replace UserTestOrder with existing factory methods

    UserTestOrder could not be decorated, making it difficult to decorate
    the behavior of the test setup. Using existing factory methods better
    enables a project to modify the test scenario to fit their project
    requirements

    API-200
    Matt Duffy

*   Adds highlight to active category in api docs

    API-189
    Ivana Veliskova

*   Adds page title related to current page with correct formatting and updates header appropriately on each API page

    API-187
    Ivana Veliskova

*   Adds logo throughout api layout documentation

    API-186
    Ivana Veliskova

*   Adds storefront and admin api links to layout navigation

    API-188
    Ivana Veliskova

*   Set order source when placing an order through the storefront api

    API-193
    Matt Duffy

*   Includes workarea logo in api docs

    API-186
    Ivana Veliskova


Workarea Api 4.0.7 (2018-02-06)
--------------------------------------------------------------------------------


Workarea Api 4.0.7 (2018-02-06)
--------------------------------------------------------------------------------

*   Generate documentation as part of release task

    In the release task, run `bin/rails test` with `GENERATE_API_DOCS` set
    to true in order to build docs, then upload docs to Git.

    API-119
    Tom Scott


Workarea Api 4.0.6 (2018-01-19)
--------------------------------------------------------------------------------

*  Remove Redcarpet dependency 


Workarea Api 4.0.5 (2017-10-03)
--------------------------------------------------------------------------------

*   Adds highlight to active category in api docs

    API-189
    Ivana Veliskova

*   Adds page title related to current page with correct formatting and updates header appropriately on each API page

    API-187
    Ivana Veliskova

*   Adds logo throughout api layout documentation

    API-186
    Ivana Veliskova

*   Adds storefront and admin api links to layout navigation

    API-188
    Ivana Veliskova

*   Includes workarea logo in api docs

    API-186
    Ivana Veliskova


Workarea Api 4.0.4 (2017-09-06)
--------------------------------------------------------------------------------

*   Fix search abandonment tests

    Broken due to new logic to prevent excessive abandonment

    API-192
    Ben Crouse


Workarea Api 4.0.3 (2017-09-06)
--------------------------------------------------------------------------------

*   Use Api::Storefront::ApplicationController namespace to prevent constant resolution errors

    API-185
    Dave Barnow

*   Restart checkout after reset to ensure cart remains associated to user

    API-181
    Matt Duffy


Workarea Api 4.0.2 (2017-08-23)
--------------------------------------------------------------------------------

*   Upgrade API user permissions partial

    API-184
    Curt Howard


Workarea Api 4.0.1 (2017-08-22)
--------------------------------------------------------------------------------

*   Only format Request Body json on the client side

    API-183
    Curt Howard

*   Clean up API docs presentation

    API-165
    Curt Howard

*   Improve validation error messaging output

    To make errors easier to find, parse and relate to causes, this
    separates errors into a better data structure. NOTE, this is a slight
    breaking change to API that should be fine for now since no one is using
    the gem yet.

    API-179
    Ben Crouse

*   Update Rakefile to work with latest updates to test setup

    API-178
    Matt Duffy


Workarea Api 4.0.0 (2017-08-15)
--------------------------------------------------------------------------------

*   Decorate #current_user to prevent issues with content block rendering

    API-175
    Matt Duffy

*   Add content documentation example

    API-158
    Curt Howard

*   Disable CORS protection

    This allows web views or sites hosting on different domains access to
    use the API.

    API-133
    Ben Crouse

*   Respect login locking when trying to generate an auth token

    API-170
    Ben Crouse

*   Add endpoint to show a taxon with its children

    API-174
    Ben Crouse

*   Add categories index endpoint

    API-173
    Ben Crouse

*   Fix checking out with orders that are already placed

    API-166
    Ben Crouse

*   Clean authentication tokens when a user changes password

    API-169
    Ben Crouse

*   Ensure if an order belongs to a user, it requires authentication

    API-167
    Ben Crouse

*   Fix documentation for analytics save filters

    API-164
    Dave Barnow

*   Include rendered html in content blocks for storefront api

    API-160
    Matt Duffy

*   Add better support for asset urls in storefront API

    - Adds asset endpoint
    - Adds field in block data of urls for assets in the block

    API-156
    Matt Duffy

*   Properly validate email signups

    API-137
    Curt Howard

*   Add checkout endpoint to storefront API

    API-131
    Matt Duffy

*   Add cart endpoints to storefront api

    API-135
    Matt Duffy

*   Remove name from product images

    API-152
    Curt Howard

*   Add SKU param to product documentation

    API-151
    Curt Howard

*   Blacklist thumb image processor

    The `thumb` is not as it seems.

    API-150
    Curt Howard

*   Add orders endpoint for storefront api

    API-139
    Matt Duffy

*   Add recommendations endpoints

    API-143
    Curt Howard

*   Add storefront API endpoints for pages and system content

    API-140
    Matt Duffy

*   Add product endpoints

    API-141
    Curt Howard

*   Add password endpoints

    API-148
    Curt Howard

*   Add email signup endpoints

    API-137
    Curt Howard

*   Add menus endpoints

    API-129
    Curt Howard

*   Add user saved credit card endpoints for storefront api

    API-147
    Matt Duffy

*   Add saved addresses endpoints for storefront api

    API-146
    Matt Duffy

*   Add recent views endpoints

    API-142
    Ben Crouse

*   Add search endpoints

    API-144
    Ben Crouse

*   Add analytics endpoints

    API-134
    Ben Crouse

*   Create contacts endpoint

    API-129
    Curt Howard

*   Add categories endpoint

    API-129
    Curt Howard

*   Fix separation of admin/storefront documentation

    Having separate engines, I had to hack apart a fair bit of Raddocs to
    achieve the goal of having two running groups of docs. At some point in
    the future, we'll probably want to look into writing/maintaining our own
    gem for this but for now, this should do.

    API-132
    Ben Crouse

*   Add storefront authentication infrastructure

    API-130
    Ben Crouse


Workarea API 3.0.2 (2017-07-07)
--------------------------------------------------------------------------------

*   Fix PaymentsDocumentationTest classname

    This test had the incorrect name PagesDocumentationTest, which caused
    the left navigation of the documentation to muddle Pages and Payment
    into the same section

    API-126
    Curt Howard


Workarea API 3.0.1 (2017-06-08)
--------------------------------------------------------------------------------

*   Update to use VCR included in base

    Use the VCR installation included in base to allow cassette additions
    and overrides.

    API-121
    Ben Crouse


Workarea API 3.0.0 (2017-05-26)
--------------------------------------------------------------------------------

*   Update README

    API-115
    Ben Crouse

*   Get raddocs working again

    API-115
    Ben Crouse

*   Move to v3 namespace

    API-115
    Ben Crouse

*   Add new infrastructure for documentation tests

    API-115
    Ben Crouse

*   Convert request specs to tests and get them working

    API-115
    Ben Crouse

*   Run renaming scripts

    API-115
    Ben Crouse


WebLinc API 2.1.2 (2016-12-06)
--------------------------------------------------------------------------------

*   Don't use error as_json for not found handling

    Using as_json is dangerous - it can cause an infinite loop depending on
    how the error class is constructed and whether it has any
    self-referential instance variables.

    API-113
    Ben Crouse


WebLinc API 2.1.1 (2016-10-11)
--------------------------------------------------------------------------------

*   Fix tests for v2.3 compatibility

    API-109
    Ben Crouse


WebLinc API 2.1.0 (2016-08-01)
--------------------------------------------------------------------------------

*   Fixes acceptance test payload for cancel_items

    API-107
    Dave Barnow

*   Allow release_id to be included in api requests

    When a patch/put request attempts to update a product, if a release
    id was included on the request, it will save the changes with that
    release rather than on the current live version of the resource

    API-106
    Matt Duffy


WebLinc API 2.0.3 (2016-05-23)
--------------------------------------------------------------------------------

*   Fix missing type declaration for api permissions

    API-104
    Ben Crouse


WebLinc API 2.0.2 (2016-04-06)
--------------------------------------------------------------------------------

*   Resolve issues with specs

    API-102
    Matt Duffy


WebLinc API 2.0.1 (2016-04-04)
--------------------------------------------------------------------------------


WebLinc API 2.0.0 (February 18, 2016)
--------------------------------------------------------------------------------

*   Rewrite all endpoints

*   Add new endpoints (payments, shipments, recommendations, etc)

*   Add bulk upsert endpoints for all major resources

*   Change authentication to use HTTP basic auth with user login credentials

*   Add API permission to user edit page in the admin (required to use the API)

*   Add Mongoid::AuditLog tracking to any change made through the API

*   Add event source for events published by API requests

*   Add rspec_api_documentation and raddocs for documentation generated from tests


WebLinc API 1.0.0
--------------------------------------------------------------------------------

*   Update for compatibility with WebLinc 2.0

*   Properly add hash params to product permitted params

    Permitted params was removing arrays of value within the filter
    and details hash of product params. Rather than try to dynamically
    white list the keys of a hash, it now instead merges in the filters
    and details explicitly.

    API-83
    Fixes: API-84


WebLinc API 0.12.0 (October 7, 2015)
--------------------------------------------------------------------------------

*   Skip CSRF token verification on API controllers

    If this isn't already a problem being hacked around, it will be in the
    future. API controllers cannot enforce CSRF protection because they
    don't need to and additionally make token-based API authentication much
    harder than it needs to be. We probably never saw this issue because the
    API was traditionally made for reading data, and CSRF protection is only valid for
    POST/PUT/DELETE calls.

    API-76

*   Update for compatibility with the WebLinc v0.12 Ruby API.

*   Upload product images with a remote URL

    When `image_url` is passed as a parameter to `POST /api/products/1/images`,
    we're now using Dragonfly to pull down the file at that URL and uploading
    it to our CDN.

    API-81

*   Upload image data encoded as URL-safe Base64

    This seems to have always been the intention of the API's product image
    uploader...to take in base64-encoded binary image data directly from the
    request. While we're also supporting URL-based image uploading, this is
    the means by which clients who have nothing online (who would normally
    have to FTP all the images over and establish some kind of convention)
    can upload all of their media through this API endpoint.

    API-80

*   Fix sample data error when no reviews

    Running sample data without the reviews plugin installed results in an
    uninitialized constant `Weblinc::Review` error. Within the review
    decorator, check for the reviews plugin before decorating
    `Weblinc::Review`.

    API-77


WebLinc API 0.11.0 (August 21, 2015)
--------------------------------------------------------------------------------

*   Fix circular reference in pages request spec.

    27ebe2f3988cbef5ffc041811a5a457443e95514

*   Add endpoints for reviews.

    1cd45613d5eb9491852f98edc3defadf2eb38289

*   Update content for compatibility with WebLinc 0.11.

    8462a669b9f20ca3ffb0132ec78bb55822d58b95

*   Add CREATE and UPDATE methods for categories.

    API-67

    95d90113e3068841d770a5bc0a4d3a41d06605f4
    84599c152298513b336ecf07773635bdbdac9564

*   Fix tests to pass on ruby 2.2.

    2d3ab7a91a4c3d3ff8a13f0450558f5154643f3a


WebLinc API 0.10.0 (July 11, 2015)
--------------------------------------------------------------------------------

*   Update for compatibility with weblinc 0.10.0.

    43b9e222ce21687c6ffe7de8dab8210e9929c635

*   Fix documentation of `Weblinc::Api.config.auth_token` in `README`.

    e558396e0acbd91995c9ebfde74637413c62db32


WebLinc API 0.9.0 (June 1, 2015)
--------------------------------------------------------------------------------

*   Validate product details/filters are arrays of scalar values.

    Previously, the ProductsController was merging the contents of the
    details and filters hash onto the hash validated by strong_parameters.
    We are now incorporating the validation that details/filters are arrays
    of scalar values in accordance with strong_parameters' slightly
    hard-to-comprehend API:
    https://github.com/rails/strong_parameters#permitted-scalar-values

    This should fix the issue of product details/filters not being checked
    to ensure they are the proper type through the API.

    API-60

*   Fix randomly failing specs.

*   Update for compatibility with weblinc 0.9.0.

    da40c95485ac9e656d9c55921d5e3a3bde6d83f1

*   Fix 'variant' misspelling in variants controller

    API-59

*   Add full API documentation.

    API-50

*   Move gift cards API functionality from weblinc-gift_cards to weblinc-api.

    GIFTCARDS-50

*   Fix decorator missing `with` option.

    API-58

*   Move wish lists API functionality from weblinc-wish_lists to weblinc-api.

    WISHLISTS-45


WebLinc API 0.8.0 (April 10, 2015)
--------------------------------------------------------------------------------

*   Conform to the [JSON API spec](http://jsonapi.org/).

    This change redefines all API v1 endpoints and ensures proper use of HTTP
    headers, json-based exception handling, and adds consistency to the format
    of responses. Additionally, the API specs have been updated to reflect the
    changes, to improve consistency across specs, and to ensure better test
    coverage.

    Updated API documentation is forthcoming in an upcoming patch release.

*   Update testing environment for compatibility with WebLinc 0.8.0.

*   Use new decorator style for consistency with WebLinc 0.8.0.

*   Remove gems server secrets for consistency with WebLinc 0.8.0.
