require 'test_helper'

module Workarea
  module Api
    module Admin
      class ProductsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_product
                                .as_json
                                .except('_id', 'slug', 'last_indexed_at')
        end

        def test_lists_products
          products = [create_product, create_product]
          get admin_api.products_path
          result = JSON.parse(response.body)['products']

          assert_equal(3, result.length)
          assert_equal(products.second, Catalog::Product.new(result.first))
          assert_equal(products.first, Catalog::Product.new(result.second))
        end

        def test_lists_filtered_products
          products = [create_product, create_product]

          travel_to 1.week.from_now

          get admin_api.products_path(
            updated_at_starts_at: 2.days.ago,
            updated_at_ends_at: 1.day.ago
          )
          result = JSON.parse(response.body)['products']
          assert_equal(0, result.length)

          get admin_api.products_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['products']
          assert_equal(0, result.length)

          get admin_api.products_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.day.from_now
          )

          result = JSON.parse(response.body)['products']
          assert_equal(3, result.length)

          get admin_api.products_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['products']
          assert_equal(3, result.length)
        end

        def test_creates_products
          assert_difference 'Catalog::Product.count', 1 do
            post admin_api.products_path, params: { product: @sample_attributes }
          end
        end

        def test_shows_products
          product = create_product
          get admin_api.product_path(product.id)
          result = JSON.parse(response.body)['product']
          assert_equal(product, Catalog::Product.new(result))
        end

        def test_updates_products
          product = create_product
          patch admin_api.product_path(product.id), params: { product: { name: 'foo' } }

          product.reload
          assert_equal('foo', product.name)
        end

        def test_bulk_upserts_products
          data = [@sample_attributes] * 10

          assert_difference 'Catalog::Product.count', 10 do
            patch admin_api.bulk_products_path, params: { products: data }
          end
        end

        def test_destroys_products
          product = create_product

          assert_difference 'Catalog::Product.count', -1 do
            delete admin_api.product_path(product.id)
          end
        end
      end
    end
  end
end
