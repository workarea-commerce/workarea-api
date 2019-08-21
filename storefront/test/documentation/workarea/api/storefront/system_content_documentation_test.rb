require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class SystemContentDocumentationTest < DocumentationTest
        resource 'System Content'

        def test_and_document_show_home_page
          description 'Showing the home page'
          route storefront_api.system_content_path('home_page')
          explanation <<-EOS
            This endpoint returns everything you'll need to render the home
            page.
          EOS

          content = Content.for('Home Page')
          content.blocks.create!(
            area: :default,
            type: :text,
            data: { text: 'Summer is here!' }
          )
          content.blocks.create!(
            area: :default,
            type: :text,
            data: { text: 'Get 20% off all swimwear' }
          )

          record_request do
            get storefront_api.system_content_path('home_page')
            assert_equal(200, response.status)
          end
        end

        def test_and_document_show
          description 'Showing system content'
          route storefront_api.system_content_path(':name')
          explanation <<-EOS
            System content is content for an area of site not configured by the
            CMS. Examples would be content for the cart page, content for
            checkout, site layout content, etc. The home page is also an example
            of system content and shown in a separate example.
          EOS

          content = Content.for('Layout')
          content.blocks.create!(
            area: :header_promo,
            type: :text,
            data: { text: 'Don\'t miss our sizzling summer deals!' }
          )
          content.blocks.create!(
            area: :footer_navigation,
            type: :text,
            data: { text: 'Be the first to received our exclusive discounts' }
          )

          record_request do
            get storefront_api.system_content_path('layout')
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
