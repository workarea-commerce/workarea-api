require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class ProductsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Products'

        def sample_attributes
          create_product.as_json.except('_id', 'slug', 'last_indexed_at')
        end

        def test_and_document_index
          description 'Listing products'
          route admin_api.products_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_product }

          record_request do
            get admin_api.products_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a product'
          route admin_api.products_path

          record_request do
            post admin_api.products_path, params: sample_attributes, as: :json
            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a product'
          route admin_api.product_path(':id')

          product = create_product

          record_request do
            get admin_api.product_path(product.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a product'
          route admin_api.product_path(':id')

          product = create_product

          record_request do
            patch admin_api.product_path(product.id),
                    params: sample_attributes,
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting products'
          route admin_api.bulk_products_path

          record_request do
            patch admin_api.bulk_products_path,
                    params: { products: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a product'
          route admin_api.product_path(':id')

          product = create_product

          record_request do
            delete admin_api.product_path(product.id), as: :json
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
