require 'test_helper'

module Workarea
  module Api
    module Storefront
      class MenusIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        include Workarea::Storefront::IntegrationTest

        setup :set_navigation_menu

        def set_navigation_menu
          @menus = ['Men', 'Women', 'Children'].map do |name|
            first_level = create_taxon(
              name: name,
              url: "http://example.com/#{name.downcase}"
            )

            second_level = first_level.children.create!(name: 'Sale')

            menu = create_menu(taxon: first_level)

            content = Content.for(menu)
            content.blocks.create!(
              type: 'taxonomy',
              data: { 'start' => second_level.id }
            )

            menu
          end

          @menu = @menus.first
        end

        def test_lists_menus
          get storefront_api.menus_path
          result = JSON.parse(response.body)

          assert_equal(@menus.count, result['menus'].count)
        end

        def test_shows_menus
          get storefront_api.menu_path(@menu)
          result = JSON.parse(response.body)

          result_block = result['content_blocks'].first
          assert_equal(@menu.id.to_s, result['id'])
          assert_equal(1, result['content_blocks'].count)
          assert_equal('taxonomy', result_block['type'])
        end
      end
    end
  end
end
