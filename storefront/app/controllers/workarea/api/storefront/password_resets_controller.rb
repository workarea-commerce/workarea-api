module Workarea
  module Api
    module Storefront
      class PasswordResetsController < Api::Storefront::ApplicationController
        def create
          password_reset = Workarea::User::PasswordReset.setup!(params[:email])

          Workarea::Storefront::AccountMailer
            .password_reset(password_reset.id.to_s)
            .deliver_later

          head :ok
        end
      end
    end
  end
end
