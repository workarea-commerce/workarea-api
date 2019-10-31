require 'test_helper'

module Workarea
  module Api
    module Admin
      class PricingSkusIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_pricing_sku.as_json.except('_id')
        end

        def test_lists_pricing_skus
          pricing_skus = [
            create_pricing_sku(id: '1'),
            create_pricing_sku(id: '2')
          ]
          get admin_api.pricing_skus_path
          result = JSON.parse(response.body)['pricing_skus']

          assert_equal(3, result.length)
          assert_equal(pricing_skus.second, Pricing::Sku.new(result.first))
          assert_equal(pricing_skus.first, Pricing::Sku.new(result.second))

          travel_to 1.week.from_now

          get admin_api.pricing_skus_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['pricing_skus']

          assert_equal(0, result.length)

          get admin_api.pricing_skus_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['pricing_skus']

          assert_equal(0, result.length)

          get admin_api.pricing_skus_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['pricing_skus']
          assert_equal(3, result.length)

          get admin_api.pricing_skus_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['pricing_skus']
          assert_equal(3, result.length)
        end

        def test_creates_pricing_skus
          assert_difference 'Pricing::Sku.count', 1 do
            post admin_api.pricing_skus_path,
              params: { pricing_sku: @sample_attributes.merge('id' => '1') }
          end
        end

        def test_shows_pricing_skus
          pricing_sku = create_pricing_sku(id: 'foo')
          get admin_api.pricing_sku_path('foo')
          result = JSON.parse(response.body)['pricing_sku']
          assert_equal(pricing_sku, Pricing::Sku.new(result))
        end

        def test_updates_pricing_skus
          pricing_sku = create_pricing_sku(id: 'foo')
          patch admin_api.pricing_sku_path('foo'),
            params: { pricing_sku: { discountable: false } }

          refute(pricing_sku.reload.discountable?)
        end

        def test_bulk_upserts_pricing_skus
          count = 0
          data = Array.new(10) do
            count += 1
            @sample_attributes.merge('id' => count)
          end

          assert_difference 'Pricing::Sku.count', 10 do
            patch admin_api.bulk_pricing_skus_path, params: { pricing_skus: data }
          end
        end

        def test_destroys_pricing_skus
          create_pricing_sku(id: 'foo')

          assert_difference 'Pricing::Sku.count', -1 do
            delete admin_api.pricing_sku_path('foo')
          end
        end
      end
    end
  end
end
