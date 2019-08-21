require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class SavedAddressesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Saved Addresses'

        def user
          @user ||= create_user
        end

        def sample_attributes
          {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          }
        end

        def create_saved_address
          @count ||= 0
          @count += 1

          user.addresses.create!(
            sample_attributes.merge(street: "#{@count} S 3rd St")
          )
        end

        def test_and_document_index
          description 'Listing saved address'
          route admin_api.user_saved_addresses_path(':user_id')

          2.times { create_saved_address }

          record_request do
            get admin_api.user_saved_addresses_path(user.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a saved address'
          route admin_api.user_saved_addresses_path(':user_id')

          record_request do
            post admin_api.user_saved_addresses_path(user.id),
                  params: { saved_address: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a saved address'
          route admin_api.user_saved_address_path(':user_id', ':id')

          saved_address = create_saved_address

          record_request do
            patch admin_api.user_saved_address_path(user.id, saved_address.id),
                    params: { saved_address: { street: '1 Foobar Lane' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a saved address'
          route admin_api.user_saved_address_path(':user_id', ':id')

          saved_address = create_saved_address

          record_request do
            delete admin_api.user_saved_address_path(user.id, saved_address.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
