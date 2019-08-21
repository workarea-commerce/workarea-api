require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class AuthenticationDocumentationTest < DocumentationTest
        include AuthenticationTest

        resource 'Authentication'

        setup :set_user

        def set_user
          @user = create_user(password: 'p@assword!')
        end

        def distance_of_time_in_words(*args)
          ApplicationController.helpers.distance_of_time_in_words(*args)
        end

        def test_creating_an_authentication_token
          description 'Creating an authentication token'
          route storefront_api.authentication_tokens_path
          explanation <<-EOS
            Creating an authentication token is the first step in user
            authentication. You will use this token to authenticate requests on
            behalf of the user going forward. To get a token you can use to
            authenticate an account, use this endpoint. You'll need the email
            and password from the user, and we'll issue a token that can be used
            to authenticate further requests for that customer. This token will
            expire after #{distance_of_time_in_words(Workarea.config.authentication_token_expiration)}.
            Tokens are also invalidated when a user changes their password. See
            the "using an authentication token" example for how to use an
            authentication token.
          EOS

          record_request do
            post storefront_api.authentication_tokens_path,
              params: { email: @user.email, password: 'p@assword!' },
              as: :json

            assert(response.ok?)
          end
        end

        def test_using_an_authentication_token
          description 'Using an authentication token'
          route storefront_api.account_path
          explanation <<-EOS
            After obtaining an authentication token you can use it to request
            authenticated endpoints by including it in the Authorization header
            on the request, as demonstrated in this example.
          EOS

          auth = @user.authentication_tokens.create!

          record_request do
            get storefront_api.account_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) }

            assert(response.ok?)
          end
        end

        def test_refreshing_an_authentication_token
          description 'Refreshing an authentication token'
          route storefront_api.authentication_tokens_path
          explanation <<-EOS
            Refreshing an authentication token extends its expiration so that it
            can continue to be used.
          EOS

          auth = @user.authentication_tokens.create!

          record_request do
            patch storefront_api.authentication_tokens_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) }
          end
        end
      end
    end
  end
end
