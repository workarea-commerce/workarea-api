module Workarea
  module Api
    module Storefront
      class SearchesController < Api::Storefront::ApplicationController
        before_action :cache_page

        def index
          search_query = QueryString.new(params[:q]).sanitized

          render(nothing: true) && (return) if search_query.blank?
          autocomplete_params = params.permit(:q)
          search = Search::SearchSuggestions.new(autocomplete_params)

          @results = search.results.map do |result|
            SearchSuggestionViewModel.new(result).to_h
          end
        end

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
