require 'test_helper'

module Workarea
  module Api
    module Storefront
      class CheckoutsIntegrationTest < IntegrationTest
        include OrdersTest

        setup :set_product, :set_order, :set_checkout_data

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

        def set_checkout_data
          create_shipping_service(name: 'Standard', rates: [{ price: 5.to_m }])
          create_shipping_service(name: 'Express', rates: [{ price: 10.to_m }])
          create_shipping_service(name: 'Overnight', rates: [{ price: 20.to_m }])
        end

        def address
          {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US'
          }
        end

        def test_preventing_checkout_with_a_placed_order
          order = create_placed_order

          get storefront_api.cart_path(order)
          refute(response.ok?)
          assert_equal(404, response.status)

          get storefront_api.checkout_path(order)
          refute(response.ok?)
          assert_equal(404, response.status)

          patch storefront_api.checkout_path(order)
          refute(response.ok?)
          assert_equal(404, response.status)

          post storefront_api.complete_checkout_path(order)
          refute(response.ok?)
          assert_equal(404, response.status)

          get storefront_api.reset_checkout_path(order)
          refute(response.ok?)
          assert_equal(404, response.status)
        end

        def test_show
          get storefront_api.checkout_path(@order)
          results = JSON.parse(response.body)
          order = results['order']

          assert(order['id'].present?)
          refute(order['user_id'].present?)

          checkout = results['checkout']
          assert(checkout['started_at'].present?)

          assert(checkout['addresses'].present?)
          refute(checkout['addresses']['complete'])

          assert(checkout['shipping'].present?)
          refute(checkout['shipping']['complete'])

          assert(checkout['payment'].present?)
          refute(checkout['payment']['complete'])
        end

        def test_update
          patch storefront_api.checkout_path(@order),
            params: {
              email: 'test@workarea.com',
              shipping_address: address,
              billing_address: address,
            }

          results = JSON.parse(response.body)
          order = results['order']
          checkout = results['checkout']

          assert(checkout['addresses']['complete'])
          assert_equal('test@workarea.com', order['email'])

          shipping_address = order['shipping_address']
          assert(shipping_address.present?)
          assert_equal('Ben', shipping_address['first_name'])
          assert_equal('Crouse', shipping_address['last_name'])
          assert_equal('22 S. 3rd St.', shipping_address['street'])
          assert_equal('Second Floor', shipping_address['street_2'])
          assert_equal('PA', shipping_address['region'])
          assert_equal('US', shipping_address['country'])
          assert_equal('19106', shipping_address['postal_code'])

          billing_address = order['billing_address']
          assert(billing_address.present?)
          assert_equal('Ben', billing_address['first_name'])
          assert_equal('Crouse', billing_address['last_name'])
          assert_equal('22 S. 3rd St.', billing_address['street'])
          assert_equal('Second Floor', billing_address['street_2'])
          assert_equal('PA', billing_address['region'])
          assert_equal('US', billing_address['country'])
          assert_equal('19106', billing_address['postal_code'])

          shipping_options = checkout['shipping']['shipping_options']
          assert(shipping_options.present?)
          assert_equal('Standard', shipping_options.first['name'])
          assert_equal('Express', shipping_options.second['name'])
          assert_equal('Overnight', shipping_options.third['name'])

          patch storefront_api.checkout_path(order['id']),
            params: { shipping_service: 'Express' }

          checkout = JSON.parse(response.body)['checkout']
          assert(checkout['shipping']['complete'])

          assert_equal('Express', checkout['shipping']['shipping_service'])
          assert_equal(1000, checkout['shipping']['shipping_total']['cents'])
        end

        def test_complete
          patch storefront_api.checkout_path(@order),
            params: {
              email: 'test@workarea.com',
              shipping_address: address,
              billing_address: address,
              shipping_service: 'Express',
            }
          result = JSON.parse(response.body)

          assert(result['checkout']['shipping']['complete'])

          post storefront_api.complete_checkout_path(result['order']['id']),
            params: {
              payment: 'new_card',
              credit_card: {
                number: '1',
                month: '1',
                year: Time.now.year + 1,
                cvv: '999'
              }
            }
          result = JSON.parse(response.body)

          assert(result['order']['placed_at'])
          assert_equal(2000, result['order']['pricing']['total_price']['cents'])

          tender = result['order']['tenders'].first
          assert_equal('credit_card', tender['type'])
          assert_equal(2000, tender['amount']['cents'])

          order = Order.first
          assert_equal('storefront_api', order.source)
        end

        def test_reset
          patch storefront_api.checkout_path(@order),
            params: {
              email: 'test@workarea.com',
              shipping_address: address,
              billing_address: address,
            }

          results = JSON.parse(response.body)
          order = results['order']
          checkout = results['checkout']

          assert(checkout['addresses']['complete'])
          started_at = checkout['started_at']
          assert(started_at.present?)

          get storefront_api.reset_checkout_path(order['id'])
          checkout = JSON.parse(response.body)['checkout']

          refute(checkout['addresses']['complete'])
          refute_equal(started_at, checkout['started_at'])
        end
      end
    end
  end
end
