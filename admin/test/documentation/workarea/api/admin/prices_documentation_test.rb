require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class PricesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Prices'

        def pricing_sku
          @pricing_sku ||= create_pricing_sku
        end

        def sample_attributes
          { regular: 15 }
        end

        def create_price
          pricing_sku.prices.create!(sample_attributes)
        end

        def test_and_document_index
          description 'Listing pricing sku prices'
          route admin_api.pricing_sku_prices_path(':pricing_sku_id')
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_price }

          record_request do
            get admin_api.pricing_sku_prices_path(pricing_sku.id),
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a pricing sku price'
          route admin_api.pricing_sku_prices_path(':pricing_sku_id')

          record_request do
            post admin_api.pricing_sku_prices_path(pricing_sku.id),
                  params: { price: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a pricing sku price'
          route admin_api.pricing_sku_price_path(':pricing_sku_id', ':id')

          price = create_price

          record_request do
            patch admin_api.pricing_sku_price_path(pricing_sku.id, price.id),
                    params: { price: { regular: 15 } }

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a pricing sku price'
          route admin_api.pricing_sku_price_path(':pricing_sku_id', ':id')

          price = create_price

          record_request do
            delete admin_api.pricing_sku_price_path(pricing_sku.id, price.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
