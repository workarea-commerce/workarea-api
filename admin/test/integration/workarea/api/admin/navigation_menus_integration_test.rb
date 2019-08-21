require 'test_helper'

module Workarea
  module Api
    module Admin
      class NavigationMenusIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_menu.as_json.except('_id')
        end

        def test_lists_menus
          2.times { create_menu }
          get admin_api.navigation_menus_path
          result = JSON.parse(response.body)['navigation_menus']
          assert_equal(3, result.length)
        end

        def test_creates_menus
          assert_difference 'Navigation::Menu.count', 1 do
            post admin_api.navigation_menus_path,
              params: { navigation_menu: @sample_attributes }
          end
        end

        def test_shows_menus
          menu = create_menu
          get admin_api.navigation_menu_path(menu.id)
          result = JSON.parse(response.body)['navigation_menu']
          assert_equal(menu, Navigation::Menu.new(result))
        end

        def test_updates_menus
          menu = create_menu
          patch admin_api.navigation_menu_path(menu.id),
            params: { navigation_menu: { name: 'foo' } }

          assert_equal('foo', menu.reload.name)
        end

        def test_destroys_menus
          menu = create_menu

          assert_difference 'Navigation::Menu.count', -1 do
            delete admin_api.navigation_menu_path(menu.id)
          end
        end
      end
    end
  end
end
