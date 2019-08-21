module Workarea
  module Api
    module Storefront
      class ProductsController < Api::Storefront::ApplicationController
        before_action :cache_page

        def show
          model = Workarea::Catalog::Product.active.find_by(slug: params[:id])
          @product = Workarea::Storefront::ProductViewModel.wrap(
            model,
            view_model_options
          )
        end
      end
    end
  end
end
