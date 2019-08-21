require 'test_helper'

module Workarea
  module Api
    module Admin
      class FulfillmentsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        def create_fulfillment(*args)
          order = create_placed_order(*args)
          Fulfillment.find(order.id)
        end

        def test_lists_fulfillments
          fulfillments = [create_fulfillment(id: '1'), create_fulfillment(id: '2')]
          get admin_api.fulfillments_path
          result = JSON.parse(response.body)['fulfillments']

          assert_equal(2, result.length)
          assert_equal(fulfillments.second, Fulfillment.new(result.first))
          assert_equal(fulfillments.first, Fulfillment.new(result.second))
        end

        def test_shows_fulfillments
          fulfillment = create_fulfillment
          get admin_api.fulfillment_path(fulfillment.id)
          result = JSON.parse(response.body)['fulfillment']
          assert_equal(fulfillment, Fulfillment.new(result))
        end

        def test_ships_items
          fulfillment = create_fulfillment
          former_status = fulfillment.status

          post admin_api.ship_items_fulfillment_path(fulfillment.id),
            params: {
              tracking_number: '1Z',
              items: [
                { id: fulfillment.items.first.order_item_id, quantity: 1 }
              ]
            }

          refute_equal(former_status, fulfillment.reload.status)
        end

        def test_cancels_items
          fulfillment = create_fulfillment
          former_status = fulfillment.status

          post admin_api.cancel_items_fulfillment_path(fulfillment.id),
            params: {
              items: [
                { id: fulfillment.items.first.order_item_id, quantity: 1 }
              ]
            }

          refute_equal(former_status, fulfillment.reload.status)
        end
      end
    end
  end
end
