require 'test_helper'

module Workarea
  module Api
    module Admin
      class FulfillmentSkusIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_fulfillment_sku.as_json.except('_id')
        end

        def test_lists_fulfillment_skus
          fulfillment_skus = [
            create_fulfillment_sku(id: '1'),
            create_fulfillment_sku(id: '2')
          ]
          get admin_api.fulfillment_skus_path
          result = JSON.parse(response.body)['fulfillment_skus']

          assert_equal(3, result.length)
          assert_equal(fulfillment_skus.second, Fulfillment::Sku.new(result.first))
          assert_equal(fulfillment_skus.first, Fulfillment::Sku.new(result.second))

          travel_to 1.week.from_now

          get admin_api.fulfillment_skus_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['fulfillment_skus']

          assert_equal(0, result.length)

          get admin_api.fulfillment_skus_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['fulfillment_skus']

          assert_equal(0, result.length)

          get admin_api.fulfillment_skus_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['fulfillment_skus']
          assert_equal(3, result.length)

          get admin_api.fulfillment_skus_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['fulfillment_skus']
          assert_equal(3, result.length)
        end

        def test_creates_fulfillment_skus
          assert_difference 'Fulfillment::Sku.count', 1 do
            post admin_api.fulfillment_skus_path,
              params: { fulfillment_sku: @sample_attributes.merge('id' => '1') }
          end
        end

        def test_shows_fulfillment_skus
          fulfillment_sku = create_fulfillment_sku(id: 'foo')
          get admin_api.fulfillment_sku_path('foo')
          result = JSON.parse(response.body)['fulfillment_sku']
          assert_equal(fulfillment_sku, Fulfillment::Sku.new(result))
        end

        def test_updates_fulfillment_skus
          fulfillment_sku = create_fulfillment_sku(id: 'foo')
          patch admin_api.fulfillment_sku_path('foo'),
            params: { fulfillment_sku: { policy: 'shipping' } }

          assert_equal('shipping', fulfillment_sku.reload.policy)
        end

        def test_bulk_upserts_fulfillment_skus
          count = 0
          data = Array.new(10) do
            count += 1
            @sample_attributes.merge('id' => count)
          end

          assert_difference 'Fulfillment::Sku.count', 10 do
            patch admin_api.bulk_fulfillment_skus_path, params: { fulfillment_skus: data }
          end
        end

        def test_destroys_fulfillment_skus
          create_fulfillment_sku(id: 'foo')

          assert_difference 'Fulfillment::Sku.count', -1 do
            delete admin_api.fulfillment_sku_path('foo')
          end
        end
      end
    end
  end
end
