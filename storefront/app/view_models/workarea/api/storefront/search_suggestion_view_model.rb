module Workarea
  module Api
    module Storefront
      class SearchSuggestionViewModel < ApplicationViewModel
        def url
          helpers = Api::Storefront::Engine.routes.url_helpers

          if suggestion_type == 'product'
            helpers.product_path(product)
          elsif suggestion_type == 'search'
            helpers.search_path(q: name)
          elsif suggestion_type == 'category'
            helpers.category_path(source['slug'])
          elsif suggestion_type == 'page'
            helpers.page_path(source['slug'])
          end
        end
      end
    end
  end
end
