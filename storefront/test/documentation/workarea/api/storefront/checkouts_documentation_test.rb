require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class CheckoutsDocumentationTest < DocumentationTest
        include OrdersTest

        resource 'Checkout'

        setup :set_product, :set_order, :set_checkout_data

        def set_product
          @product = create_product(
            id: 'VINTEE',
            name: 'Vintage Tee',
            variants: [
              { sku: 'VT001', regular: 5.to_m },
              { sku: 'VT002', regular: 6.to_m }
            ]
          )

          create_inventory(id: 'VT001', policy: 'standard', available: 2)
        end

        def set_order
          @order = create_order(email: 'sbaker@workarea.com')
          add_item(@order, product_id: @product.id, sku: 'VT001', quantity: 2)
        end

        def set_checkout_data
          create_shipping_service(name: 'Standard', rates: [{ price: 5.to_m }])
          create_shipping_service(name: 'Express', rates: [{ price: 10.to_m }])
          create_shipping_service(name: 'Overnight', rates: [{ price: 20.to_m }])
        end

        def address
          {
            first_name: 'Susan',
            last_name: 'Baker',
            street: '350 Fifth Avenue',
            city: 'New York',
            region: 'NY',
            country: 'US',
            postal_code: '10118',
            phone_number: '6465552390'
          }
        end

        def test_and_document_show
          description 'Showing a checkout'
          route storefront_api.checkout_path(':id')
          explanation <<-EOS
            This will give you overview of the state of checkout for the
            associated order ID. It includes full order information, as well
            as summary information for each step of checkout.
          EOS

          record_request do
            get storefront_api.checkout_path(@order)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a checkout'
          route storefront_api.checkout_path(':id')
          explanation <<-EOS
            Use this endpoint to make updates to checkout. This will typically
            mean setting addresses and shipping options for the checkout.
          EOS

          record_request do
            patch storefront_api.checkout_path(@order),
              as: :json,
              params: {
                email: 'susanb@workarea.com',
                shipping_address: address,
                billing_address: address,
                shipping_service: 'Express'
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_update_failure
          description 'Failure to update a checkout'
          route storefront_api.checkout_path(':id')
          explanation <<-EOS
            This is an example of what occurs when you fail to send in the correct parameters for your checkout.
          EOS

          record_request do
            patch storefront_api.checkout_path(@order),
              as: :json,
              params: {
                email: 'susanb@workarea.com',
                shipping_address: address.except(:first_name),
                billing_address: address.except(:last_name),
                shipping_service: 'Express'
              }

            assert_equal(422, response.status)
          end
        end

        def test_and_document_complete
          description 'Completing a checkout'
          route storefront_api.complete_checkout_path(':id')
          explanation <<-EOS
            This endpoint completes checkout and places the order. Payment
            tender information is required at this point, and should be included
            with this request.
          EOS

          patch storefront_api.checkout_path(@order),
            as: :json,
            params: {
              email: 'susanb@workarea.com',
              shipping_address: address,
              billing_address: address,
              shipping_service: 'Express'
            }

          order = JSON.parse(response.body)['order']

          record_request do
            post storefront_api.complete_checkout_path(order['id']),
              as: :json,
              params: {
                payment: 'new_card',
                credit_card: {
                  number: '4111111111111111',
                  month: '3',
                  year: Time.now.year + 2,
                  cvv: '123'
                }
              }
            assert_equal(200, response.status)
          end
        end

        def test_and_document_reset
          description 'Showing a checkout'
          route storefront_api.reset_checkout_path(':id')
          explanation <<-EOS
            This endpoint resets the checkout by wiping all private information
            from the order and it's associated models. Use it for handling
            timeouts, logouts, and any other situation where you want to ensure
            the safety of the customer's information.
          EOS

          record_request do
            get storefront_api.reset_checkout_path(@order)
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
