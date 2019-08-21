require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class NavigationMenusDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Navigation menus'

        def sample_attributes
          create_menu.as_json.except('_id', 'slug')
        end

        def test_and_document_index
          description 'Listing menus'
          route admin_api.navigation_menus_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_menu }

          record_request do
            get admin_api.navigation_menus_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a menu'
          route admin_api.navigation_menus_path

          record_request do
            post admin_api.navigation_menus_path,
                  params: { navigation_menu: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a navigation menu'
          route admin_api.navigation_menu_path(':id')

          record_request do
            get admin_api.navigation_menu_path(create_menu.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a navigation menus'
          route admin_api.navigation_menu_path(':id')

          record_request do
            patch admin_api.navigation_menu_path(create_menu.id),
                    params: { navigation_menu: { name: 'foo' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a navigation menu'
          route admin_api.navigation_menu_path(':id')

          record_request do
            delete admin_api.navigation_menu_path(create_menu.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
