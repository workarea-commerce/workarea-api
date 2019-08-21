require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class UsersDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Users'

        def sample_attributes
          @count ||= 0
          @count += 1

          create_user
            .as_json
            .except('_id', 'password_digest', 'name', 'super_admin', 'token')
            .merge('email' => "user#{@count}@workarea.com", 'password' => 'p@ssw0rd')
        end

        def test_and_document_index
          description 'Listing users'
          route admin_api.users_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_user }

          record_request do
            get admin_api.users_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a user'
          route admin_api.users_path

          record_request do
            post admin_api.users_path, params: { user: sample_attributes }, as: :json
            assert_equal(201, response.status)
          end
        end

        def test_and_document_show_by_id
          description 'Showing a user by ID'
          route admin_api.user_path(':id')

          record_request do
            get admin_api.user_path(create_user.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_show_by_email
          description 'Showing a user by email'
          route admin_api.user_path(':email')

          user = create_user(email: 'test@workarea.com')

          record_request do
            get admin_api.user_path(URI.escape(user.email, '+@.'))
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a user'
          route admin_api.user_path(':id')

          record_request do
            patch admin_api.user_path(create_user.id),
                    params: { user: sample_attributes },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting users'
          route admin_api.bulk_users_path

          record_request do
            patch admin_api.bulk_users_path,
                    params: { users: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a user'
          route admin_api.user_path(':id')

          user = create_user

          record_request do
            delete admin_api.user_path(user.id), as: :json
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
