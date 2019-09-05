module Workarea
  module Api
    module Storefront
      class SearchesController < Api::Storefront::ApplicationController
        before_action :cache_page

        def show
          response = Search::StorefrontSearch.new(params.to_unsafe_h).response
          @search = Workarea::Storefront::SearchViewModel.new(
            response,
            view_model_options
          )
        end
      end
    end
  end
end
