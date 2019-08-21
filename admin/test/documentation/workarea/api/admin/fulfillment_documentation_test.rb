require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class FulfillmentDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Fulfillment'

        def create_fulfillment(*args)
          order = create_placed_order(*args)
          Fulfillment.find(order.id)
        end

        def fulfillment
          @fulfillment ||= create_fulfillment
        end

        def test_and_document_index
          description 'Listing fulfillments'
          route admin_api.fulfillments_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          create_fulfillment(id: '1')
          create_fulfillment(id: '2')

          record_request do
            get admin_api.fulfillments_path
            assert_equal(200, response.status)
          end
        end

        def test_and_document_show
          description 'Showing fulfillment'
          route admin_api.fulfillment_path(':order_id')

          record_request do
            get admin_api.fulfillment_path(create_fulfillment.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_ship_items
          description 'Marking items as shipped'
          route admin_api.ship_items_fulfillment_path(':order_id')

          record_request do
            post admin_api.ship_items_fulfillment_path(fulfillment.id),
                  params: {
                    tracking_number: '1Z',
                    items: [
                      { id: fulfillment.items.first.order_item_id, quantity: 1 }
                    ]
                  },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_cancel_items
          description 'Marking items as canceled'
          route admin_api.cancel_items_fulfillment_path(':order_id')

          record_request do
            post admin_api.cancel_items_fulfillment_path(fulfillment.id),
                  params: {
                    items: [
                      { id: fulfillment.items.first.order_item_id, quantity: 1 }
                    ]
                  },
                  as: :json

            assert_equal(201, response.status)
          end
        end
      end
    end
  end
end
