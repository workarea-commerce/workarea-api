require 'test_helper'

module Workarea
  module Api
    module Admin
      class PagesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_page.as_json.except('_id', 'slug')
        end

        def test_lists_pages
          pages = [create_page, create_page]
          get admin_api.pages_path
          result = JSON.parse(response.body)['pages']

          assert_equal(3, result.length)
          assert_equal(pages.second, Content::Page.new(result.first))
          assert_equal(pages.first, Content::Page.new(result.second))

          travel_to 1.week.from_now

          get admin_api.pages_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['pages']

          assert_equal(0, result.length)

          get admin_api.pages_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['pages']

          assert_equal(0, result.length)

          get admin_api.pages_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['pages']
          assert_equal(3, result.length)

          get admin_api.pages_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['pages']
          assert_equal(3, result.length)
        end

        def test_creates_pages
          assert_difference 'Content::Page.count', 1 do
            post admin_api.pages_path, params: { page: @sample_attributes }
          end
        end

        def test_shows_pages
          page = create_page
          get admin_api.page_path(page.id)
          result = JSON.parse(response.body)['page']
          assert_equal(page, Content::Page.new(result))
        end

        def test_updates_pages
          page = create_page
          patch admin_api.page_path(page.id), params: { page: { name: 'foo' } }

          page.reload
          assert_equal('foo', page.name)
        end

        def test_bulk_upserts_pages
          data = [@sample_attributes] * 10

          assert_difference 'Content::Page.count', 10 do
            patch admin_api.bulk_pages_path, params: { pages: data }
          end
        end

        def test_destroys_pages
          page = create_page

          assert_difference 'Content::Page.count', -1 do
            delete admin_api.page_path(page.id)
          end
        end
      end
    end
  end
end
