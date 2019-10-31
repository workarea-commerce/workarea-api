require 'test_helper'

module Workarea
  module Api
    module Storefront
      class OrdersIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include AuthenticationTest

        setup :set_user
        setup :set_order

        def set_user
          @user = create_user(first_name: 'Ben', last_name: 'Crouse')
          set_current_user(@user)
        end

        def set_order
          @order = begin
            order = Order.new(user_id: @user.id, email: @user.email)

            product = create_product(
              name: 'Product One',
              variants: [{ sku: 'PROD1', regular: 5.to_m }]
            )
            order.add_item(product_id: product.id, sku: 'PROD1', quantity: 2)

            product = create_product(
              name: 'Product Two',
              variants: [{ sku: 'PROD2', regular: 10.to_m }]
            )
            order.add_item(product_id: product.id, sku: 'PROD2', quantity: 1)

            product = create_product(
              name: 'Product Three',
              variants: [{ sku: 'PROD3', regular: 20.to_m }]
            )
            order.add_item(
              product_id: product.id,
              sku: 'PROD3',
              quantity: 1,
              customizations: { 'foo' => 'bar' }
            )

            complete_checkout(
              order,
              shipping_service: create_shipping_service(name: 'Express').name,
              credit_card: {
                number: '4111111111111111',
                month: '3',
                year: Time.now.year + 2,
                cvv: '123'
              }

            )

            fulfillment = Fulfillment.find(order.id)
            fulfillment.ship_items(
              '1Z',
              [{ 'id' => order.items.first.id, 'quantity' => 2 }]
            )

            fulfillment.cancel_items(
              [{ 'id' => order.items.second.id, 'quantity' => 1 }]
            )

            order
          end
        end

        def test_index
          get storefront_api.orders_path
          result = JSON.parse(response.body)

          assert_equal(@user.id.to_s, result['user_id'])
          assert_equal(1, result['orders'].count)
          assert_equal(@order.id.to_s, result['orders'].last['id'])
        end

        def test_show
          get storefront_api.order_path(@order)
          results = JSON.parse(response.body)
          order = results['order']

          assert_equal(@user.id.to_s, order['user_id'])
          assert_equal(@order.id, order['id'])
          assert(order['placed_at'].present?)

          assert(order['shipping_address'].present?)
          assert(order['shipping_service'].present?)

          assert(order['billing_address'].present?)
          assert_equal(1, order['tenders'].count)

          pricing = order['pricing']
          assert(pricing['shipping_total'].present?)
          assert(pricing['tax_total'].present?)
          assert(pricing['subtotal_price'].present?)
          assert(pricing['total_price'].present?)
          assert(pricing['paid_amount'].present?)

          assert_equal(3, order['items'].count)
          assert(order['items'].one? { |i| i['customizations'].present? })

          fulfillment = results['fulfillment']
          assert(fulfillment['status'].present?)
          assert_equal(1, fulfillment['packages'].count)
          assert(fulfillment['packages'].first['tracking_number'].present?)
          assert_equal(1, fulfillment['packages'].first['items'].count)
          assert_equal(1, fulfillment['pending_items'].count)
          assert_equal(1, fulfillment['canceled_items'].count)
        end
      end
    end
  end
end
