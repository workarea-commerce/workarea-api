require 'test_helper'

module Workarea
  module Api
    module Admin
      class InventorySkusIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_inventory.as_json.except('_id')
        end

        def test_lists_inventory_skus
          inventory_skus = [create_inventory(id: '1'), create_inventory(id: '2')]
          get admin_api.inventory_skus_path
          result = JSON.parse(response.body)['inventory_skus']

          assert_equal(3, result.length)
          assert_equal(inventory_skus.second, Inventory::Sku.new(result.first))
          assert_equal(inventory_skus.first, Inventory::Sku.new(result.second))

          travel_to 1.week.from_now

          get admin_api.inventory_skus_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['inventory_skus']

          assert_equal(0, result.length)

          get admin_api.inventory_skus_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['inventory_skus']

          assert_equal(0, result.length)

          get admin_api.inventory_skus_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['inventory_skus']
          assert_equal(3, result.length)

          get admin_api.inventory_skus_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['inventory_skus']
          assert_equal(3, result.length)
        end

        def test_creates_inventory_skus
          data = @sample_attributes.merge(id: '1')

          assert_difference 'Inventory::Sku.count', 1 do
            post admin_api.inventory_skus_path, params: { inventory_sku: data }
          end
        end

        def test_shows_inventory_skus
          inventory_sku = create_inventory(id: 'foo')
          get admin_api.inventory_sku_path('foo')
          result = JSON.parse(response.body)['inventory_sku']
          assert_equal(inventory_sku, Inventory::Sku.new(result))
        end

        def test_updates_inventory_skus
          inventory_sku = create_inventory(id: 'foo')
          patch admin_api.inventory_sku_path('foo'),
            params: { inventory_sku: { policy: 'ignore' } }

          assert_equal('ignore', inventory_sku.reload.policy)
        end

        def test_bulk_upserts_inventory_skus
          count = 0
          data = Array.new(10) do
            count += 1
            @sample_attributes.merge(id: count)
          end

          assert_difference 'Inventory::Sku.count', 10 do
            patch admin_api.bulk_inventory_skus_path, params: { inventory_skus: data }
          end
        end

        def test_destroys_inventory_skus
          create_inventory(id: 'foo')

          assert_difference 'Inventory::Sku.count', -1 do
            delete admin_api.inventory_sku_path('foo')
          end
        end
      end
    end
  end
end
