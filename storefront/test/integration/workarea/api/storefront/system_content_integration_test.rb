require 'test_helper'

module Workarea
  module Api
    module Storefront
      class SystemContentIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include Workarea::Storefront::IntegrationTest

        setup :set_content

        def set_content
          @content = Content.for('Layout')
          @content.blocks.create!(
            area: :header_promo,
            type: :text,
            data: { text: 'text' }
          )
          @content.blocks.create!(
            area: :footer_navigation,
            type: :text,
            data: { text: 'text' }
          )
        end

        def test_shows_categories
          get storefront_api.system_content_path('layout')
          result = JSON.parse(response.body)

          assert_equal(@content.id.to_s, result['id'])
          assert_equal(2, result['content_blocks'].count)
        end
      end
    end
  end
end
