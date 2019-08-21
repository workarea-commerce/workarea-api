require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class OrdersDocumentationTest < DocumentationTest
        include AuthenticationTest

        resource 'Orders'

        setup :set_user
        setup :set_order

        def set_user
          @user = create_user(
            email: 'sbaker@workarea.com',
            first_name: 'Susan',
            last_name: 'Baker'
          )
        end

        def set_order
          @order ||= begin
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

            address = {
              first_name: 'Susan',
              last_name: 'Baker',
              street: '350 Fifth Avenue',
              city: 'New York',
              region: 'NY',
              country: 'US',
              postal_code: '10118',
              phone_number: '6465552390'
            }

            complete_checkout(
              order,
              shipping_address: address,
              billing_address: address,
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

        def test_and_show_index_of_orders
          description "Listing the user's orders"
          route storefront_api.orders_path
          explanation <<-EOS
            This endpoints returns recently placed orders for a customer. Use it
            for showing an order history for the customer.
          EOS

          auth = @user.authentication_tokens.create!

          record_request do
            get storefront_api.orders_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_show_a_single_order
          description 'Showing an order'
          route storefront_api.order_path(':id')
          explanation <<-EOS
            This endpoint returns everything needed to render an order for a
            customer's order history including order details and fulfillment
            status.
          EOS

          auth = @user.authentication_tokens.create!

          record_request do
            get storefront_api.order_path(@order),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) }

            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
