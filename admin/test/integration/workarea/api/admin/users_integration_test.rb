require 'test_helper'

module Workarea
  module Api
    module Admin
      class UsersIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        def sample_attributes
          @count ||= 0
          @count += 1

          create_user
            .as_json
            .except('_id', 'token')
            .merge('email' => "api#{@count}@workarea.com")
        end

        def test_lists_users
          users = [create_user, create_user]
          get admin_api.users_path
          result = JSON.parse(response.body)['users']

          assert_equal(3, result.length) # plus one for API auth
          assert_equal(users.second, User.new(result.first))
          assert_equal(users.first, User.new(result.second))
        end

        def test_filtered_users
          create_user
          create_user

          travel_to 1.week.from_now

          get admin_api.users_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['users']

          assert_equal(0, result.length)

          get admin_api.users_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['users']

          assert_equal(0, result.length)

          get admin_api.users_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['users']
          assert_equal(3, result.length) # plus one for API auth

          get admin_api.users_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['users']
          assert_equal(3, result.length) # plus one for API auth
        end

        def test_creates_users
          data = sample_attributes
          assert_difference 'User.count', 1 do
            post admin_api.users_path, params: { user: data }
          end
        end

        def test_shows_users
          user = create_user(email: 'test@workarea.com')

          get admin_api.user_path(user.id)
          result = JSON.parse(response.body)['user']
          assert(result['password_digest'].blank?)
          assert_equal(user, User.new(result))

          get admin_api.user_path(URI.escape(user.email, '+@.'))
          result = JSON.parse(response.body)['user']
          assert(result['password_digest'].blank?)
          assert_equal(user, User.new(result))
        end

        def test_updates_users
          user = create_user
          patch admin_api.user_path(user.id), params: { user: { first_name: 'Foo' } }
          assert_equal('Foo', user.reload.first_name)
        end

        def test_bulk_upserts_users
          data = Array.new(10) { sample_attributes }
          assert_difference 'User.count', 10 do
            patch admin_api.bulk_users_path, params: { users: data }
          end
        end

        def test_destroys_users
          user = create_user

          assert_difference 'User.count', -1 do
            delete admin_api.user_path(user.id)
          end
        end
      end
    end
  end
end
