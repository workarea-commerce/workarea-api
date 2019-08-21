require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class PricingSkusDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Pricing SKUs'

        def sample_attributes
          @sample_attributes ||= create_pricing_sku.as_json.except('_id')
        end

        def test_and_document_index
          description 'Listing pricing SKUs'
          route admin_api.pricing_skus_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { |i| create_pricing_sku(id: "SKU#{i}") }

          record_request do
            get admin_api.pricing_skus_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating an pricing SKU'
          route admin_api.pricing_skus_path

          record_request do
            post admin_api.pricing_skus_path,
                  params: { pricing_sku: sample_attributes.merge('_id' => 'SKU2') },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing an pricing SKU'
          route admin_api.pricing_sku_path(':id')

          record_request do
            get admin_api.pricing_sku_path(create_pricing_sku.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating an pricing SKU'
          route admin_api.pricing_sku_path(':id')

          record_request do
            patch admin_api.pricing_sku_path(create_pricing_sku.id),
                    params: { pricing_sku: { discountable: false } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting pricing SKUs'
          route admin_api.bulk_pricing_skus_path

          record_request do
            data = Array.new(3) { sample_attributes.merge('_id' => Pricing::Sku.count) }
            patch admin_api.bulk_pricing_skus_path,
                    params: { pricing_skus: data },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing an pricing SKU'
          route admin_api.pricing_sku_path(':id')

          record_request do
            delete admin_api.pricing_sku_path(create_pricing_sku.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
