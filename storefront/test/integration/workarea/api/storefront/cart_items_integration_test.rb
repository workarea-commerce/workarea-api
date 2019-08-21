require 'test_helper'

module Workarea
  module Api
    module Storefront
      class CartItemsIntegrationTest < IntegrationTest
        include OrdersTest
        include Workarea::Storefront::CatalogCustomizationTestClass

        setup :set_product, :set_order

        def set_product
          @product = create_product(
            name: 'Test Product',
            variants: [
              { sku: 'SKU1', regular: 5.to_m },
              { sku: 'SKU2', regular: 6.to_m }
            ]
          )

          create_inventory(id: 'SKU1', policy: 'standard', available: 2)
        end

        def set_order
          @order = create_order
        end

        def test_create
          post storefront_api.cart_items_path(@order),
            params: {
              product_id: @product.id,
              sku: @product.skus.first,
              quantity: 1
            }

          results = JSON.parse(response.body)
          item = results['item']
          order = results['order']

          assert_equal(1, order['items'].count)
          assert_equal(1, item['quantity'])
          assert_equal(@product.id, item['product_id'])
          assert_equal(@product.skus.first, item['sku'])
        end

        def test_create_with_limited_inventory
          post storefront_api.cart_items_path(@order),
            params: {
              product_id: @product.id,
              sku: @product.skus.first,
              quantity: 3
            }

          results = JSON.parse(response.body)
          item = results['item']
          order = results['order']

          assert_equal(1, order['items'].count)
          assert_equal(2, item['quantity'])

          messages = JSON.parse(response.headers['X-Flash-Messages'])
          assert(messages['error'].present?)
        end

        def test_create_with_inactive_sku
          @product.variants.first.update_attributes!(active: false)

          post storefront_api.cart_items_path(@order),
            params: {
              product_id: @product.id,
              sku: @product.skus.first,
              quantity: 1
            }

          results = JSON.parse(response.body)
          assert_equal(0, results['order']['items'].count)

          messages = JSON.parse(response.headers['X-Flash-Messages'])
          assert(messages['info'].present?)
        end

        def test_create_with_customizations
          @product.update_attributes(customizations: 'foo_cust')

          post storefront_api.cart_items_path(@order),
            params: {
              product_id: @product.id,
              sku: @product.skus.first,
              quantity: 1,
              foo: 'Test',
              bar: 'This'
            }
          result = JSON.parse(response.body)

          assert_equal(1, result['order']['items'].count)
          assert_equal(
            { 'foo' => 'Test', 'bar' => 'This' },
            result['item']['customizations']
          )
        end

        def test_create_with_invalid_customizations
          @product.update_attributes(customizations: 'foo_cust')

          post storefront_api.cart_items_path(@order),
            params: {
              product_id: @product.id,
              sku: @product.skus.first,
              quantity: 1,
              foo: 'Test'
            }

          result = JSON.parse(response.body)

          assert_equal(0, result['order']['items'].count)

          messages = JSON.parse(response.headers['X-Flash-Messages'])
          assert(messages['error'].present?)
        end

        def test_update
          add_item(@order, product_id: @product.id, sku: 'SKU1', quantity: 1)

          patch storefront_api.cart_item_path(@order, @order.items.first),
            params: { sku: 'SKU2', quantity: 3 }

          results = JSON.parse(response.body)
          item = results['item']
          order = results['order']

          assert_equal(1, order['items'].count)
          assert_equal(3, item['quantity'])
          assert_equal(@product.id, item['product_id'])
          assert_equal(@product.skus.last, item['sku'])
          assert_equal(1800, order['pricing']['total_price']['cents'])
        end

        def test_destroy
          add_item(@order, product_id: @product.id, sku: 'SKU1', quantity: 1)

          delete storefront_api.cart_item_path(@order, @order.items.first)
          result = JSON.parse(response.body)

          assert_equal(0, result['order']['items'].count)
        end
      end
    end
  end
end
