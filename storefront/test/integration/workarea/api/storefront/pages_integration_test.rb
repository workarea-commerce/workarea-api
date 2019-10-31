require 'test_helper'

module Workarea
  module Api
    module Storefront
      class PagesIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        setup :set_page
        setup :set_taxonomy
        setup :set_content

        def set_page
          @page = create_page
        end

        def set_taxonomy
          first_level = create_taxon(
            name: 'First Level'
          )

          @taxon = first_level.children.create!(navigable: @page)
        end

        def set_content
          content = Content.for(@page)
          content.blocks.create!(
            area: :default,
            type: :text,
            data: { text: 'text' }
          )
          content.blocks.create!(
            area: :default,
            type: :image,
            data: { image: asset.id.to_s, alt: 'Foo' }
          )
        end

        def asset
          @asset ||= create_asset
        end

        def test_shows_pages
          get storefront_api.page_path(@page)
          result = JSON.parse(response.body)

          assert_equal(@page.id.to_s, result['id'])
          assert_equal(3, result['breadcrumbs'].count)
          assert_equal(@taxon.id.to_s, result['breadcrumbs'].last['id'])
          assert_equal(2, result['content_blocks'].count)

          block = result['content_blocks'].last
          assert(block['data']['image_url'])
          assert(block['html'])
        end
      end
    end
  end
end
