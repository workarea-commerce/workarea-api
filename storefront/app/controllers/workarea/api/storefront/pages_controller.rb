module Workarea
  module Api
    module Storefront
      class PagesController < Api::Storefront::ApplicationController
        before_action :cache_page

        def show
          model = Content::Page.active.find_by(slug: params[:id])
          @page = Workarea::Storefront::PageViewModel.new(model, view_model_options)
        end
      end
    end
  end
end
