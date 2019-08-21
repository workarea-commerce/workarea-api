require 'test_helper'

module Workarea
  module Api
    module Admin
      class ContentIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_content.as_json.except('_id')
        end

        def test_lists_content
          content = [create_content, create_content]
          get admin_api.content_index_path
          result = JSON.parse(response.body)['content']

          assert_equal(3, result.length)
          assert_equal(content.second, Content.new(result.first))
          assert_equal(content.first, Content.new(result.second))
        end

        def test_creates_content
          data = @sample_attributes

          assert_difference 'Content.count', 1 do
            post admin_api.content_index_path, params: { content: data }
          end
        end

        def test_shows_content
          content = create_content
          get admin_api.content_path(content.id)
          result = JSON.parse(response.body)['content']
          assert_equal(content, Content.new(result))
        end

        def test_updates_content
          content = create_content
          patch admin_api.content_path(content.id),
            params: { content: { browser_title: 'foo' } }

          content.reload
          assert_equal('foo', content.browser_title)
        end

        def test_bulk_upserts_content
          data = [@sample_attributes] * 10

          assert_difference 'Content.count', 10 do
            patch admin_api.bulk_content_index_path, params: { content: data }
          end
        end
      end
    end
  end
end
