require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class PaymentProfilesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Payment Profiles'

        def sample_attributes
          @sample_attributes ||= create_payment_profile.as_json.except('_id')
        end

        def test_and_document_index
          description 'Listing payment profiles'
          route admin_api.payment_profiles_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { |i| create_payment_profile(reference: i) }

          record_request do
            get admin_api.payment_profiles_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a payment profile'
          route admin_api.payment_profiles_path

          record_request do
            data = sample_attributes.merge('reference' => Payment::Profile.count + 1)
            post admin_api.payment_profiles_path,
                  params: { payment_profile: data },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a payment profile'
          route admin_api.payment_profile_path(':id')

          record_request do
            get admin_api.payment_profile_path(create_payment_profile.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a payment profiles'
          route admin_api.payment_profile_path(':id')

          record_request do
            patch admin_api.payment_profile_path(create_payment_profile.id),
                    params: { payment_profile: { store_credit: 29 } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting payment profiles'
          route admin_api.bulk_payment_profiles_path

          count = Payment::Profile.count + 1
          data = Array.new(3) { sample_attributes.merge('reference' => count) }

          record_request do
            patch admin_api.bulk_payment_profiles_path,
                    params: { payment_profiles: data },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a payment profile'
          route admin_api.payment_profile_path(':id')

          record_request do
            delete admin_api.payment_profile_path(create_payment_profile.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
