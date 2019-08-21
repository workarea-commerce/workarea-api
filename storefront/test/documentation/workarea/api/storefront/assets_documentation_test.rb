require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class AssetsDocumentationTest < DocumentationTest
        resource 'Assets'

        setup :set_asset

        def set_asset
          @asset = create_asset(name: 'Summer Sale Callout')
        end

        def test_and_document_showing_assets
          description 'Showing an asset'
          route storefront_api.asset_path(':id')
          explanation <<-EOS
            Use this endpoint to look up assets stored in Workarea. Often times
            these will be referenced in content blocks.
          EOS

          record_request do
            get storefront_api.asset_path(@asset)
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
