module Workarea
  module Api
    module Storefront
      class ApplicationController < Workarea::ApplicationController
        include HttpCaching
        include Api::Storefront::Authentication
        include Api::Storefront::UserActivity

        respond_to :json

        before_action :set_json_format
        before_action :skip_session
        before_action { params.permit! }
        after_action :disable_cors_protection

        rescue_from Mongoid::Errors::DocumentNotFound, with: :handle_not_found
        rescue_from Mongoid::Errors::Validations, with: :handle_invalid
        rescue_from Mongoid::Errors::UnknownAttribute, with: :handle_unknown_attribute
        rescue_from Authentication::InvalidError, with: :handle_invalid_auth

        helper :all

        def cache_page
          expires_in Workarea.config.page_cache_ttl, public: true
        end

        def skip_session
          request.session_options[:skip] = true
        end

        private

        def set_json_format
          request.format = :json
        end

        def handle_not_found(e)
          payload = { params: e.params, problem: e.problem }
          render json: payload, status: :not_found
        end

        def handle_invalid(e)
          render(
            json: { problems: e.document.errors.full_messages },
            status: :unprocessable_entity
          )
        end

        def handle_unknown_attribute(e)
          render json: e.as_json.slice('problem'), status: :unprocessable_entity
        end

        def handle_invalid_auth
          request_http_token_authentication
        end

        def disable_cors_protection
          headers['Access-Control-Allow-Origin'] = '*'
          headers['Access-Control-Allow-Headers'] = '*'
          headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS'
        end
      end
    end
  end
end
