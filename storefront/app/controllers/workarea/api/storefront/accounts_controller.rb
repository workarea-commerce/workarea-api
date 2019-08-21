module Workarea
  module Api
    module Storefront
      class AccountsController < Api::Storefront::ApplicationController
        def show
        end

        def create
          @user = User.create!(user_params)

          Workarea::Storefront::AccountMailer
            .creation(@user.id.to_s)
            .deliver_later

          @authentication_token = @user.authentication_tokens.create!
        end

        def update
          current_user.update_attributes!(user_params)
          render :show
        end

        private

        def user_params
          params.permit(:email, :password, :first_name, :last_name)
        end
      end
    end
  end
end
