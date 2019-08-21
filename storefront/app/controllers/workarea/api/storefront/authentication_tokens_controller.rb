module Workarea
  module Api
    module Storefront
      class AuthenticationTokensController < Api::Storefront::ApplicationController
        before_action :ensure_not_locked, only: :create

        def create
          user = User.find_for_login(params[:email], params[:password])

          if user.blank?
            render(
              json: { problem: t('workarea.api.storefront.authentication_tokens.error') },
              status: :unprocessable_entity
            )
          else
            @authentication_token = User::AuthenticationToken.create!(user: user)
          end
        end

        def update
          @authentication_token = authenticate_with_http_token do |token, options|
            User::AuthenticationToken.refresh!(token, options)
          end

          if @authentication_token.blank?
            render(
              json: { problem: t('workarea.api.storefront.authentication_tokens.error') },
              status: :unprocessable_entity
            )
          end
        end

        private

        def ensure_not_locked
          if User.login_locked?(params[:email])
            render(
              json: {
                problem: t('workarea.api.storefront.authentication_tokens.login_locked')
              },
              status: :unprocessable_entity
            )

            return false
          end
        end
      end
    end
  end
end
