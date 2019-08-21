require 'test_helper'

module Workarea
  module Api
    module Admin
      class ShippingRatesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @shipping_service = create_shipping_service
          @sample_attributes = @shipping_service.rates.first.as_json.except('_id')
        end

        def create_rate
          @shipping_service.rates.create!(@sample_attributes)
        end

        def test_lists_rates
          rates = [create_rate, create_rate]
          get admin_api.shipping_service_rates_path(@shipping_service.id)
          result = JSON.parse(response.body)['rates']

          assert_equal(3, result.length) # one pre-existing rate
          assert_equal(rates.first, Shipping::Rate.new(result.second))
          assert_equal(rates.second, Shipping::Rate.new(result.third))
        end

        def test_creates_rates
          assert_difference '@shipping_service.reload.rates.count', 1 do
            post admin_api.shipping_service_rates_path(@shipping_service.id),
              params: { rate: @sample_attributes }
          end
        end

        def test_updates_rates
          rate = create_rate
          patch admin_api.shipping_service_rate_path(@shipping_service.id, rate.id),
            params: { rate: { price: 21 } }

          assert_equal(21.to_m, rate.reload.price)
        end

        def test_destroys_rates
          rate = create_rate
          assert_difference '@shipping_service.reload.rates.count', -1 do
            delete admin_api.shipping_service_rate_path(@shipping_service.id, rate.id)
          end
        end
      end
    end
  end
end
