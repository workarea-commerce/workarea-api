require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class DiscountsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Discounts'
        alias create_discount create_product_discount

        def sample_attributes
          create_discount
            .as_json
            .except('_id')
            .merge('type' => 'product', 'promo_codes' => ['SALE'])
        end

        def test_and_document_index
          description 'Listing discounts'
          route admin_api.discounts_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_discount }

          record_request do
            get admin_api.discounts_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a discount'
          route admin_api.discounts_path

          record_request do
            post admin_api.discounts_path,
                  params: { discount: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a discount'
          route admin_api.discount_path(':id')

          record_request do
            get admin_api.discount_path(create_discount.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating discounts'
          route admin_api.discount_path(':id')

          record_request do
            patch admin_api.discount_path(create_discount.id),
                    params: { discount: { name: 'foo' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a discount'
          route admin_api.discount_path(':id')

          record_request do
            delete admin_api.discount_path(create_discount.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
