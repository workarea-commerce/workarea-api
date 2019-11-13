module Workarea
  module Api
    module Storefront
      module Authentication
        extend ActiveSupport::Concern

        class InvalidError < RuntimeError; end

        included do
          helper_method :current_user
        end

        def self.find_user(token, options)
          User::AuthenticationToken.authenticate(token, options).try(:user)
        end

        def current_user
          current_visit.current_user || raise(InvalidError)
        end

        def authentication?
          current_visit.logged_in?
        end
      end
    end
  end
end
