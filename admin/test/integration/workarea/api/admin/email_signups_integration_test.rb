require 'test_helper'

module Workarea
  module Api
    module Admin
      class EmailSignupsIntegrationTest < IntegrationTest
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
        end

        def test_shows_email_signups
          email_signup = create_email_signup
          get admin_api.email_signup_path(email_signup.id)
          result = JSON.parse(response.body)['email_signup']
          assert_equal(email_signup, Email::Signup.new(result))
        end
      end
    end
  end
end
