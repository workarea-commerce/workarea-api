require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class PagesDocumentationTest < DocumentationTest
        resource 'Pages'

        setup :set_page
        setup :set_taxonomy
        setup :set_content

        def set_page
          @page = create_page(name: 'Summer Lookbook')
        end

        def set_taxonomy
          first_level = create_taxon(
            name: 'Women',
            url: "#{Workarea.config.host}/women"
          )

          @taxon = first_level.children.create!(navigable: @page)
        end

        def set_content
          content = Content.for(@page)
          content.blocks.create!(
            area: :default,
            type: :text,
            data: { text: 'Great new looks for summer' }
          )
          content.blocks.create!(
            area: :default,
            type: :image,
            data: { image: asset.id.to_s, alt: 'splash' }
          )
          content.blocks.create!(
            area: :default,
            type: :text,
            data: { text: 'Pool party fashion' }
          )
        end

        def asset
          @asset ||= create_asset(name: 'Splash')
        end

        def test_and_document_show
          description 'Showing a page'
          route storefront_api.page_path(':slug')
          explanation <<-EOS
            This endpoint will return all relevant data for showing a content
            page.
          EOS

          record_request do
            get storefront_api.page_path(@page)
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
