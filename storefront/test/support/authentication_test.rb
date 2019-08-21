module Workarea
  module Api
    module Storefront
      module AuthenticationTest
        extend ActiveSupport::Concern

        included do
          delegate :encode_credentials, to: ActionController::HttpAuthentication::Token
        end

        def set_current_user(user)
          Workarea::Api::Storefront::ApplicationController.subclasses.each do |klass|
            if klass.method_defined?(:current_user)
              klass.any_instance.stubs(:current_user).returns(user)
            end

            if klass.method_defined?(:authentication?)
              klass.any_instance.stubs(:authentication?).returns(true)
            end
          end
        end
      end
    end
  end
end
