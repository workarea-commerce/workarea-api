module Workarea
  module Api
    module Storefront
      class CategoriesController < Api::Storefront::ApplicationController
        before_action :cache_page

        def index
          models = Catalog::Category.page(params[:page]).select(&:active?)
          @categories = Workarea::Storefront::CategoryViewModel.wrap(
            models,
            view_model_options
          )
        end

        def show
          model = Catalog::Category.find_by(slug: params[:id])
          raise InvalidDisplay unless model.active?

          @category = Workarea::Storefront::CategoryViewModel.wrap(
            model,
            view_model_options
          )
        end
      end
    end
  end
end
