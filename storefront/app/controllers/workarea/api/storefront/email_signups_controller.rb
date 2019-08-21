module Workarea
  module Api
    module Storefront
      class EmailSignupsController < Api::Storefront::ApplicationController
        def show
          @email_signup = Workarea::Storefront::EmailSignupsViewModel.new
        end

        def create
          @signup = Workarea::Email::Signup.create!(email: params[:email])
        end
      end
    end
  end
end
