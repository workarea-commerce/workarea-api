module Workarea
  module Api
    module Admin
      class Engine < ::Rails::Engine
        include Workarea::Plugin
        isolate_namespace Workarea::Api::Admin

        config.after_initialize do
          Workarea::Api::Admin::Swagger.generate!
        end

        config.to_prepare do
          ApplicationDocument.include(Workarea::Api::Admin::DateFiltering)
        end
      end
    end
  end
end
