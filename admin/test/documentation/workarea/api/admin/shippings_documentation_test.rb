require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class ShippingsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Shipping'

        def test_and_document_index
          description 'Listing shipments'
          route admin_api.shippings_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_shipping }

          record_request do
            get admin_api.shippings_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a shipment'
          route admin_api.shipping_path(':id')

          record_request do
            get admin_api.shipping_path(create_shipping.id)
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
