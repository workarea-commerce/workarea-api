require 'test_helper'

module Workarea
  module Api
    module Admin
      class ShippingsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_shipping.as_json.except('_id')
        end

        def test_lists_shippings
          shippings = [create_shipping, create_shipping]
          get admin_api.shippings_path
          result = JSON.parse(response.body)['shippings']

          assert_equal(3, result.length)
          assert_equal(shippings.second, Shipping.new(result.first))
          assert_equal(shippings.first, Shipping.new(result.second))
        end

        def test_shows_shippings
          shipping = create_shipping
          get admin_api.shipping_path(shipping.id)
          result = JSON.parse(response.body)['shipping']
          assert_equal(shipping, Shipping.new(result))
        end
      end
    end
  end
end
