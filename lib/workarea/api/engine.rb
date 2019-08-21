module Workarea
  module Api
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::Api
    end
  end
end
