require 'test_helper'

module Workarea
  module Api
    module Admin
      class ShippingSkusIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_shipping_sku.as_json.except('_id')
        end

        def test_lists_shipping_skus
          shipping_skus = [
            create_shipping_sku(id: '1'),
            create_shipping_sku(id: '2')
          ]
          get admin_api.shipping_skus_path
          result = JSON.parse(response.body)['shipping_skus']

          assert_equal(3, result.length)
          assert_equal(shipping_skus.second, Shipping::Sku.new(result.first))
          assert_equal(shipping_skus.first, Shipping::Sku.new(result.second))

          travel_to 1.week.from_now

          get admin_api.shipping_skus_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['shipping_skus']

          assert_equal(0, result.length)

          get admin_api.shipping_skus_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['shipping_skus']

          assert_equal(0, result.length)

          get admin_api.shipping_skus_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['shipping_skus']
          assert_equal(3, result.length)

          get admin_api.shipping_skus_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['shipping_skus']
          assert_equal(3, result.length)
        end

        def test_creates_shipping_skus
          assert_difference 'Shipping::Sku.count', 1 do
            post admin_api.shipping_skus_path,
              params: { shipping_sku: @sample_attributes.merge('id' => '1') }
          end
        end

        def test_shows_shipping_skus
          shipping_sku = create_shipping_sku(id: 'foo')
          get admin_api.shipping_sku_path('foo')
          result = JSON.parse(response.body)['shipping_sku']
          assert_equal(shipping_sku, Shipping::Sku.new(result))
        end

        def test_updates_shipping_skus
          shipping_sku = create_shipping_sku(id: 'foo')
          patch admin_api.shipping_sku_path('foo'),
            params: { shipping_sku: { weight: 2.5 } }

          assert_equal(2.5, shipping_sku.reload.weight)
        end

        def test_bulk_upserts_shipping_skus
          count = 0
          data = Array.new(10) do
            count += 1
            @sample_attributes.merge('id' => count)
          end

          assert_difference 'Shipping::Sku.count', 10 do
            patch admin_api.bulk_shipping_skus_path, params: { shipping_skus: data }
          end
        end

        def test_destroys_shipping_skus
          create_shipping_sku(id: 'foo')

          assert_difference 'Shipping::Sku.count', -1 do
            delete admin_api.shipping_sku_path('foo')
          end
        end
      end
    end
  end
end
