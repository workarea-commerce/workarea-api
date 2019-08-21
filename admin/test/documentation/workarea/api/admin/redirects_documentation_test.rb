require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class RedirectsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Redirects'

        def sample_attributes
          @sample_attributes ||= create_redirect.as_json.except('_id')
        end

        def test_and_document_index
          description 'Listing redirects'
          route admin_api.redirects_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { |i| create_redirect(path: "/#{i}") }

          record_request do
            get admin_api.redirects_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a redirect'
          route admin_api.redirects_path

          record_request do
            post admin_api.redirects_path,
                  params: { redirect: sample_attributes.merge('path' => '/foo') },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a redirect'
          route admin_api.redirect_path(':id')

          record_request do
            get admin_api.redirect_path(create_redirect.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a redirects'
          route admin_api.redirect_path(':id')

          record_request do
            patch admin_api.redirect_path(create_redirect.id),
                    params: { redirect: { path: '/foobar' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting redirects'
          route admin_api.bulk_redirects_path

          data = Array.new(3) do
            count = Navigation::Redirect.count
            sample_attributes.merge('path' => "/foo#{count}")
          end

          record_request do
            patch admin_api.bulk_redirects_path, params: { redirects: data }, as: :json
            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a redirect'
          route admin_api.redirect_path(':id')

          record_request do
            delete admin_api.redirect_path(create_redirect.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
