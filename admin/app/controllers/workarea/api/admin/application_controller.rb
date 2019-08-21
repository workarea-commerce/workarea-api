module Workarea
  module Api
    module Admin
      class ApplicationController < Workarea::ApplicationController
        include CurrentRelease
        include ::Swagger::Blocks

        respond_to :json

        before_action :current_user # to force HTTP basic auth
        before_action :set_json_format
        before_action { params.permit! }
        around_action :audit_log

        rescue_from Mongoid::Errors::DocumentNotFound, with: :handle_not_found
        rescue_from Mongoid::Errors::Validations, with: :handle_invalid
        rescue_from Mongoid::Errors::UnknownAttribute, with: :handle_unknown_attribute

        def current_user
          return @current_user if defined?(@current_user)

          if user = authenticate_with_http_basic { |u, p| Api::Admin.authenticate(u, p) }
            @current_user = user
          else
            request_http_basic_authentication
          end
        end

        def sort_field
          params[:sort_by].presence || :created_at
        end

        def sort_direction
          if params[:sort_direction].in?(%w(asc desc))
            params[:sort_direction]
          else
            :desc
          end
        end

        private

        def current_release_id
          params[:release_id]
        end

        def set_json_format
          request.format = :json
        end

        def handle_not_found(e)
          payload = { params: e.params, problem: e.problem }
          render json: payload, status: :not_found
        end

        def handle_invalid(e)
          payload = { problem: e.summary, document: e.document }
          render json: payload, status: :unprocessable_entity
        end

        def handle_unknown_attribute(e)
          render json: e.as_json.slice('problem'), status: :unprocessable_entity
        end

        def audit_log
          Mongoid::AuditLog.record(current_user) do
            yield
          end
        end
      end
    end
  end
end
