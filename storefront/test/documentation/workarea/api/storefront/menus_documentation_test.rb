require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class MenusDocumentationTest < DocumentationTest
        resource 'Menus'

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
        end

        def test_and_document_index
          description 'Listing menus'
          route storefront_api.menus_path
          explanation <<-EOS
            In the base HTML storefront, menus are used as the primary top-level
            navigation entry points. Each menu has associated content (composed
            of content blocks) that represent the navigation to be display when
            that menu is selected (usually a hover or a click on a mobile
            device). Each menu points at a particular spot in the taxonomy.
          EOS

          record_request do
            get storefront_api.menus_path
            assert_equal(200, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a menu'
          route storefront_api.menu_path(':id')
          explanation <<-EOS
            This endpoint will return all the data used to render a menu. This
            includes the corresponding content, as well a link to where the
            menu points at in the taxonomy.
          EOS

          record_request do
            get storefront_api.menu_path(@menus.first)
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
