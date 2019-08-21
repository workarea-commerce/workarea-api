module Workarea
  module Api
    module Storefront
      class Engine < ::Rails::Engine
        include Workarea::Plugin
        isolate_namespace Workarea::Api::Storefront
      end
    end
  end
end
