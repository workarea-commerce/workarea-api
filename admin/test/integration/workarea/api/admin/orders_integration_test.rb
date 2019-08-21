require 'test_helper'

module Workarea
  module Api
    module Admin
      class OrdersIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        def test_lists_orders
          orders = [create_order, create_order]
          get admin_api.orders_path
          result = JSON.parse(response.body)['orders']

          assert_equal(2, result.length)
          assert_equal(orders.second, Order.new(result.first))
          assert_equal(orders.first, Order.new(result.second))
        end

        def test_filters_orders
          orders = [
            create_order(email: 'foo@workarea.com', placed_at: 1.week.ago),
            create_order(email: 'bar@workarea.com', placed_at: 2.days.ago)
          ]

          get admin_api.orders_path(
            placed_at_greater_than: 3.days.ago,
            placed_at_less_than: 1.days.ago
          )

          result = JSON.parse(response.body)['orders']

          assert_equal(1, result.length)
          assert_equal(orders.second, Order.new(result.first))

          get admin_api.orders_path(email: 'foo@workarea.com')

          result = JSON.parse(response.body)['orders']

          assert_equal(1, result.length)
          assert_equal(orders.first, Order.new(result.first))

          travel_to 1.week.from_now

          get admin_api.orders_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['orders']

          assert_equal(0, result.length)

          get admin_api.orders_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['orders']

          assert_equal(0, result.length)

          get admin_api.orders_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['orders']
          assert_equal(2, result.length)

          get admin_api.orders_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['orders']
          assert_equal(2, result.length)
        end

        def test_shows_orders
          order = create_placed_order
          payment = Payment.find(order.id)
          fulfillment = Fulfillment.find(order.id)
          shipping = Shipping.find_by_order(order.id)

          get admin_api.order_path(order.id)
          result = JSON.parse(response.body)

          assert_equal(order, Order.new(result['order']))
          assert_equal(payment, Payment.new(result['payment']))
          assert_equal(fulfillment, Fulfillment.new(result['fulfillment']))
          assert_equal(shipping, Shipping.new(result['shippings'].first))
        end
      end
    end
  end
end
