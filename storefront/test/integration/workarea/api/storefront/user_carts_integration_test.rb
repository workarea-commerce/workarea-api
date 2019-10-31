require 'test_helper'

module Workarea
  module Api
    module Storefront
      class UserCartsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include AuthenticationTest
        include OrdersTest

        setup :set_user, :set_product, :set_order

        def set_user
          @user = create_user(first_name: 'Ben', last_name: 'Crouse')
          set_current_user(@user)
        end

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
          @order = create_order(user_id: @user.id.to_s, email: @user.email)
          add_item(@order, product_id: @product.id, sku: 'SKU1', quantity: 2)
        end

        def test_index_user_carts
          get storefront_api.carts_path
          result = JSON.parse(response.body)

          assert_equal(@user.id.to_s, result['user_id'])
          assert_equal(1, result['orders'].count)

          order = result['orders'].first
          assert_equal(@order.id, order['id'])
        end

        def test_new_cart_for_user
          post storefront_api.carts_path
          result = JSON.parse(response.body)

          assert(result['id'].present?)
          assert(result['user_id'].present?)
        end
      end
    end
  end
end
