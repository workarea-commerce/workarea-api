require 'test_helper'

module Workarea
  class User
    class AuthenticationTokenTestCase < TestCase
      setup :set_user

      def set_user
        @user = create_user
      end

      def test_authenticate
        assert(AuthenticationToken.authenticate('asflkjasdflkjas').blank?)

        auth = AuthenticationToken.create!(user: @user)
        assert_equal(auth, AuthenticationToken.authenticate(auth.token))
      end

      def test_expired
        auth = AuthenticationToken.create!(user: @user)
        refute(auth.expired?)

        expired = (Workarea.config.authentication_token_expiration + 1.day).from_now
        travel_to expired

        assert(auth.expired?)
      end
    end
  end
end
