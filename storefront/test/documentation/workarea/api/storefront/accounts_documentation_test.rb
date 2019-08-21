require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class AccountsDocumentationTest < DocumentationTest
        include AuthenticationTest

        resource 'Accounts'

        def test_showing_an_account
          description 'Getting account details'
          route storefront_api.account_path

          user = create_user
          auth = user.authentication_tokens.create!

          record_request do
            get storefront_api.account_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_creating_an_account
          description 'Creating an account'
          route storefront_api.account_path
          explanation <<-EOS
            This endpoint does three things: it creates an account, it creates
            an authentication token, and it sends an account creation email to
            the customer.
          EOS

          record_request do
            post storefront_api.account_path,
              as: :json,
              params: {
                email: 'bob@workarea.com',
                password: 'areallysecurepassword'
              }

            assert_equal(200, response.status)
          end
        end

        def test_updating_an_account
          description 'Updating an account'
          route storefront_api.account_path

          user = create_user
          auth = user.authentication_tokens.create!

          record_request do
            get storefront_api.account_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) },
              as: :json,
              params: {
                email: 'billy@workarea.com',
                password: 'adifferentbutstillreallysecurepassword'
              }

            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
