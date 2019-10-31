require 'test_helper'

module Workarea
  module Api
    module Storefront
      class CartsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        include AuthenticationTest
        include OrdersTest

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
          add_item(@order, product_id: @product.id, sku: 'SKU1', quantity: 2)
        end

        def test_new_cart
          post storefront_api.carts_path
          result = JSON.parse(response.body)

          assert(result['id'].present?)
          refute(result['user_id'].present?)
        end

        def test_show
          get storefront_api.cart_path(@order)
          result = JSON.parse(response.body)

          assert_equal(@order.id, result['id'])
          assert_equal(1, result['items'].count)
          assert_equal(2, result['items'].first['quantity'])
        end

        def test_invalid_user
          user = create_user
          auth = user.authentication_tokens.create!

          # don't allow authenticated users to grab guest checkouts
          get storefront_api.cart_path(@order),
            headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) }

          refute(response.ok?)
          assert_equal(404, response.status)

          # don't allow users to grab other users's checkouts
          other_user = create_user
          @order.update_attributes!(user_id: other_user.id)

          get storefront_api.cart_path(@order),
            headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) }

          refute(response.ok?)
          assert_equal(404, response.status)

          # don't allow anonymous users to grab other users's checkouts
          get storefront_api.cart_path(@order)
          refute(response.ok?)
          assert_equal(401, response.status)
        end

        def test_check_inventory
          add_item(@order, product_id: @product.id, sku: 'SKU1', quantity: 2)

          get storefront_api.cart_path(@order)
          result = JSON.parse(response.body)

          messages = JSON.parse(response.headers['X-Flash-Messages'])
          assert(messages['error'].present?)

          assert_equal(2, result['items'].first['quantity'])
        end

        def test_purchasable_items
          @product.variants.first.update_attributes!(active: false)

          get storefront_api.cart_path(@order)
          result = JSON.parse(response.body)

          messages = JSON.parse(response.headers['X-Flash-Messages'])
          assert(messages['info'].present?)

          assert(result['items'].blank?)
        end

        def test_add_promo_code
          create_order_total_discount(promo_codes: %w(TESTCODE))

          post storefront_api.add_promo_code_to_cart_path(@order),
            params: { promo_code: 'TESTCODE' }
          result = JSON.parse(response.body)

          assert_equal(@order.id, result['id'])
          assert_equal(%w(TESTCODE), result['promo_codes'])
          assert_equal(
            'Order Total Discount',
            result['pricing']['price_adjustments'].first['description']
          )
        end
      end
    end
  end
end
