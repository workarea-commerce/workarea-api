require 'test_helper'

module Workarea
  module Api
    module Admin
      class PricesIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sku = create_pricing_sku
          @sample_attributes = { regular: 15 }
        end

        def create_price
          @sku.prices.create!(@sample_attributes)
        end

        def test_lists_prices
          prices = [create_price, create_price]
          get admin_api.pricing_sku_prices_path(@sku.id)
          result = JSON.parse(response.body)['prices']

          assert_equal(2, result.length)
          assert_equal(prices.first, Pricing::Price.new(result.first))
          assert_equal(prices.second, Pricing::Price.new(result.second))
        end

        def test_creates_prices
          assert_difference '@sku.reload.prices.count', 1 do
            post admin_api.pricing_sku_prices_path(@sku.id),
              params: { price: @sample_attributes }
          end
        end

        def test_updates_prices
          price = create_price
          patch admin_api.pricing_sku_price_path(@sku.id, price.id),
            params: { price: { sale: 34 } }

          assert_equal(34.to_m, price.reload.sale)
        end

        def test_destroys_prices
          price = create_price

          assert_difference '@sku.reload.prices.count', -1 do
            delete admin_api.pricing_sku_price_path(@sku.id, price.id)
          end
        end
      end
    end
  end
end
