require 'test_helper'

module Workarea
  module Api
    module Admin
      class EmailSignupsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        include Workarea::Admin::IntegrationTest

        def test_lists_email_signups
          email_signups = [
            create_email_signup(email: '1@workarea.com'),
            create_email_signup(email: '2@workarea.com')
          ]

          get admin_api.email_signups_path
          result = JSON.parse(response.body)['email_signups']

          assert_equal(2, result.length)
          assert_equal(email_signups.second, Email::Signup.new(result.first))
          assert_equal(email_signups.first, Email::Signup.new(result.second))

          travel_to 1.week.from_now

          get admin_api.email_signups_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['email_signups']

          assert_equal(0, result.length)

          get admin_api.email_signups_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['email_signups']

          assert_equal(0, result.length)

          get admin_api.email_signups_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['email_signups']
          assert_equal(2, result.length)

          get admin_api.email_signups_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['email_signups']
          assert_equal(2, result.length)
        end

        def test_shows_email_signups
          email_signup = create_email_signup(email: 'test@workarea.com')

          get admin_api.email_signup_path(email_signup.id)
          result = JSON.parse(response.body)['email_signup']
          assert_equal(email_signup, Email::Signup.new(result))

          get admin_api.email_signup_path(URI.escape(email_signup.email, '+@.'))
          result = JSON.parse(response.body)['email_signup']
          assert_equal(email_signup, Email::Signup.new(result))
        end
      end
    end
  end
end
