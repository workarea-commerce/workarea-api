module Workarea
  module Api
    module Storefront
      class MenusController < Api::Storefront::ApplicationController
        before_action :cache_page

        def index
          models = Navigation::Menu.all.select(&:active?)
          @menus = Workarea::Storefront::MenuViewModel.wrap(models, params)
        end

        def show
          model = Navigation::Menu.active.find(params[:id])
          @menu = Workarea::Storefront::MenuViewModel.wrap(model, params)
        end
      end
    end
  end
end
