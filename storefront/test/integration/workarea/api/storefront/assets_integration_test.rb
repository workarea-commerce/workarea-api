require 'test_helper'

module Workarea
  module Api
    module Storefront
      class AssetsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        setup :set_asset

        def set_asset
          @asset = create_asset
        end

        def test_shows_assets
          get storefront_api.asset_path(@asset)
          result = JSON.parse(response.body)

          assert_equal(@asset.id.to_s, result['id'])
          assert_equal(@asset.name, result['name'])
          assert_includes(result['url'], @asset.optim.url)
        end
      end
    end
  end
end
