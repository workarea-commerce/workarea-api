require 'test_helper'

module Workarea
  module Api
    module Admin
      class ContentAssetsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_asset.as_json.except('_id')
        end

        def test_lists_assets
          assets = [create_asset, create_asset]
          get admin_api.content_assets_path
          result = JSON.parse(response.body)['assets']

          assert_equal(3, result.length)
          assert_equal(assets.second, Content::Asset.new(result.first))
          assert_equal(assets.first, Content::Asset.new(result.second))

          travel_to 1.week.from_now

          get admin_api.content_assets_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['assets']

          assert_equal(0, result.length)

          get admin_api.content_assets_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['assets']

          assert_equal(0, result.length)

          get admin_api.content_assets_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['assets']
          assert_equal(3, result.length)

          get admin_api.content_assets_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['assets']
          assert_equal(3, result.length)
        end

        def test_creates_assets
          data = @sample_attributes
          assert_difference 'Content::Asset.count', 1 do
            post admin_api.content_assets_path, params: { asset: data }
          end
        end

        def test_shows_assets
          asset = create_asset
          get admin_api.content_asset_path(asset.id)
          result = JSON.parse(response.body)['asset']
          assert_equal(asset, Content::Asset.new(result))
        end

        def test_updates_assets
          asset = create_asset
          patch admin_api.content_asset_path(asset.id),
            params: { asset: { name: 'foo' } }

          asset.reload
          assert_equal('foo', asset.name)
        end

        def test_bulk_upserts_assets
          data = [@sample_attributes] * 10
          assert_difference 'Content::Asset.count', 10 do
            patch admin_api.bulk_content_assets_path, params: { assets: data }
          end
        end

        def test_destroys_assets
          asset = create_asset

          assert_difference 'Content::Asset.count', -1 do
            delete admin_api.content_asset_path(asset.id)
          end
        end
      end
    end
  end
end
