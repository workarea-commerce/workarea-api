require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class ShippingServicesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Shipping Services'

        def sample_attributes
          create_shipping_service.as_json.except('_id')
        end

        def test_and_document_index
          description 'Listing shipping_services'
          route admin_api.shipping_services_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_shipping_service }

          record_request do
            get admin_api.shipping_services_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a shipping_service'
          route admin_api.shipping_services_path

          record_request do
            post admin_api.shipping_services_path, params: sample_attributes, as: :json
            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a shipping_service'
          route admin_api.shipping_service_path(':id')

          record_request do
            get admin_api.shipping_service_path(create_shipping_service.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a shipping_service'
          route admin_api.shipping_service_path(':id')

          record_request do
            patch admin_api.shipping_service_path(create_shipping_service.id),
                    params: sample_attributes,
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting shipping_services'
          route admin_api.bulk_shipping_services_path

          record_request do
            patch admin_api.bulk_shipping_services_path,
                    params: { shipping_services: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a shipping_service'
          route admin_api.shipping_service_path(':id')

          shipping_service = create_shipping_service

          record_request do
            delete admin_api.shipping_service_path(shipping_service.id), as: :json
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
