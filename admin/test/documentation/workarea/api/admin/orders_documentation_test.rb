require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class OrdersDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Orders'

        def test_and_document_index
          description 'Listing orders'
          route admin_api.orders_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { |i| create_placed_order(id: 1000 + i) }

          record_request do
            get admin_api.orders_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc ' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_filtered_index
          description 'Viewing orders by date range'
          route admin_api.orders_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'
          parameter :placed_at_greater_than, 'Start of a placed_at date range'
          parameter :placed_at_less_than, 'End of a placed_at date range'

          3.times { |i| create_placed_order(id: 1000 + i, placed_at: i.weeks.ago) }

          record_request do
            get admin_api.orders_path,
                  params:
                    { page: 1,
                      sort_by: 'created_at',
                      sort_direction: 'desc',
                      placed_at_greater_than: 2.weeks.ago - 1.day,
                      placed_at_less_than: 2.weeks.ago + 1.day }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_show
          description 'Showing an order'
          route admin_api.order_path(':id')

          record_request do
            get admin_api.order_path(create_placed_order.id)
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
