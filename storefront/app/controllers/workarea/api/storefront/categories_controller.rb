module Workarea
  module Api
    module Storefront
      class CategoriesController < Api::Storefront::ApplicationController
        before_action :cache_page

        def index
          models = Catalog::Category.active.page(params[:page])
          @categories = Workarea::Storefront::CategoryViewModel.wrap(
            models,
            view_model_options
          )
        end

        def show
          model = Catalog::Category.find_by(slug: params[:id])
          @category = Workarea::Storefront::CategoryViewModel.wrap(
            model,
            view_model_options
          )
        end
      end
    end
  end
end
