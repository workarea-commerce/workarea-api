module Workarea
  module Api
    module Storefront
      module Authentication
        extend ActiveSupport::Concern

        class InvalidError < RuntimeError; end

        included do
          helper_method :current_user
        end

        def current_user
          return @current_user if defined?(@current_user)

          user = authenticate_with_http_token do |token, options|
            User::AuthenticationToken.authenticate(token, options).try(:user)
          end

          @current_user = user || raise(InvalidError)
        end

        def authentication?
          regex = ActionController::HttpAuthentication::Token::TOKEN_REGEX
          request.authorization.to_s[regex].present?
        end
      end
    end
  end
end
