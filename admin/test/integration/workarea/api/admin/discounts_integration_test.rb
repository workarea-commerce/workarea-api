require 'test_helper'

module Workarea
  module Api
    module Admin
      class DiscountsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes
        alias create_discount create_product_discount

        def set_sample_attributes
          @sample_attributes = create_discount
                                .as_json
                                .except('_id')
                                .merge('type' => 'product')
        end

        def test_lists_discounts
          discounts = [create_discount, create_discount]
          get admin_api.discounts_path
          result = JSON.parse(response.body)['discounts']

          assert_equal(3, result.length)
          assert_equal(discounts.second, Pricing::Discount::Product.new(result.first))
          assert_equal(discounts.first, Pricing::Discount::Product.new(result.second))

          travel_to 1.week.from_now

          get admin_api.discounts_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['discounts']

          assert_equal(0, result.length)

          get admin_api.discounts_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['discounts']

          assert_equal(0, result.length)

          get admin_api.discounts_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['discounts']
          assert_equal(3, result.length)

          get admin_api.discounts_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['discounts']
          assert_equal(3, result.length)
        end

        def test_creates_discounts
          data = @sample_attributes

          assert_difference 'Pricing::Discount.count', 1 do
            post admin_api.discounts_path, params: { discount: data }
          end
        end

        def test_shows_discounts
          discount = create_discount
          get admin_api.discount_path(discount.id)
          result = JSON.parse(response.body)['discount']
          assert_equal(discount, Pricing::Discount::Product.new(result))
        end

        def test_updates_discounts
          discount = create_discount

          patch admin_api.discount_path(discount.id),
            params: { discount: { name: 'foo' } }

          discount.reload
          assert_equal('foo', discount.name)
        end

        def test_destroys_discounts
          discount = create_discount

          assert_difference 'Pricing::Discount.count', -1 do
            delete admin_api.discount_path(discount.id)
          end
        end
      end
    end
  end
end
