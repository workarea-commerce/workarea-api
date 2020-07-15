require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class FulfillmentSkusDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Fulfillment SKUs'

        def sample_attributes
          @sample_attributes ||= create_fulfillment_sku.as_json.except('_id')
        end

        def test_and_document_index
          description 'Listing fulfillment SKUs'
          route admin_api.fulfillment_skus_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { |i| create_fulfillment_sku(id: "SKU#{i}") }

          record_request do
            get admin_api.fulfillment_skus_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating an fulfillment SKU'
          route admin_api.fulfillment_skus_path

          record_request do
            post admin_api.fulfillment_skus_path,
                  params: { fulfillment_sku: sample_attributes.merge('_id' => 'SKU2') },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing an fulfillment SKU'
          route admin_api.fulfillment_sku_path(':id')

          record_request do
            get admin_api.fulfillment_sku_path(create_fulfillment_sku.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating an fulfillment SKU'
          route admin_api.fulfillment_sku_path(':id')

          record_request do
            patch admin_api.fulfillment_sku_path(create_fulfillment_sku.id),
                    params: { fulfillment_sku: { policy: 'shipping' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting fulfillment SKUs'
          route admin_api.bulk_fulfillment_skus_path

          record_request do
            data = Array.new(3) { sample_attributes.merge('_id' => Fulfillment::Sku.count) }
            patch admin_api.bulk_fulfillment_skus_path,
                    params: { fulfillment_skus: data },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing an fulfillment SKU'
          route admin_api.fulfillment_sku_path(':id')

          record_request do
            delete admin_api.fulfillment_sku_path(create_fulfillment_sku.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
