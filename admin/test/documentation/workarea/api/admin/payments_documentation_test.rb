require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class PaymentsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Payments'

        def test_and_document_index
          description 'Listing payments'
          route admin_api.payments_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { |i| create_placed_order(id: 1000 + i) }

          record_request do
            get admin_api.payments_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_show
          description 'Showing an payment'
          route admin_api.payment_path(':id')

          record_request do
            get admin_api.payment_path(create_placed_order.id)
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
