module Workarea
  module Api
    module Admin
      class SwaggerController < Admin::ApplicationController
        include ::Swagger::Blocks

        def index
          controller = self
          self.class.send(:swagger_root) do
            key :swagger, '2.0'

            info do
              key :version, '1.0.0'
              key :title, 'Workarea Admin'
              key :description, 'A backend API for integrating and configuring Workarea'
              key :termsOfService, 'https://workarea.com'
              contact do
                key :name, 'Workarea Product Team'
              end
            end

            key :host, Workarea.config.host
            key :basePath, controller.root_path[0..-2]
            key :schemes, [Rails.application.config.force_ssl ? 'https' : 'http']
            key :consumes, ['application/json']
            key :produces, ['application/json']

            security_definition :BasicAuth do
              key :type, :basic
            end
            security do
              key :BasicAuth, []
            end
          end

          render json: ::Swagger::Blocks.build_root_json(Swagger.klasses)
        end
      end
    end
  end
end
