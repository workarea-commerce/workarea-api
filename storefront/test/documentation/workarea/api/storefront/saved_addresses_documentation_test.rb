require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class SavedAddressesDocumentationTest < DocumentationTest
        include AuthenticationTest

        resource 'Saved Addresses'

        setup :set_user
        setup :set_address

        def set_user
          @user = create_user(first_name: 'Susan', last_name: 'Baker')
          @auth = @user.authentication_tokens.create!
        end

        def set_address
          @address = @user.addresses.create!(
            first_name: 'Susan',
            last_name: 'Baker',
            street: '350 Fifth Avenue',
            city: 'New York',
            region: 'NY',
            country: 'US',
            postal_code: '10118',
            phone_number: '6465552390'
          )
        end

        def test_and_show_index_of_addresses
          @user.addresses.create!(
            first_name: 'Susan',
            last_name: 'Baker',
            street: '4059 Mt Lee Dr.',
            city: 'Hollywood',
            region: 'CA',
            country: 'US',
            postal_code: '90068',
            phone_number: '7545552390'
          )

          description "Listing the user's saved addresses"
          route storefront_api.saved_addresses_path
          explanation <<-EOS
            List a customer's saved addresses. Useful for account management and
            for using saved addresses in checkout.
          EOS

          record_request do
            get storefront_api.saved_addresses_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_show_a_single_address
          description 'Showing a saved address'
          route storefront_api.saved_address_path(':id')

          record_request do
            get storefront_api.saved_address_path(@address),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_creating_a_new_address
          description 'Creating a saved address'
          route storefront_api.saved_addresses_path

          record_request do
            post storefront_api.saved_addresses_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) },
              as: :json,
              params: {
                first_name: 'Susan',
                last_name: 'Baker',
                street: '4059 Mt Lee Dr.',
                city: 'Hollywood',
                region: 'CA',
                country: 'US',
                postal_code: '90068',
                phone_number: '7545552390'
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_updating_an_address
          description 'Updating a saved address'
          route storefront_api.saved_address_path(':id')

          record_request do
            patch storefront_api.saved_address_path(@address),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) },
              as: :json,
              params: {
                street: '4059 Mt Lee Dr.',
                city: 'Hollywood',
                region: 'CA',
                postal_code: '90068',
                phone_number: '7545552390'
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_deleting_an_address
          description 'Deleting a saved address'
          route storefront_api.saved_address_path(':id')

          record_request do
            delete storefront_api.saved_address_path(@address),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
