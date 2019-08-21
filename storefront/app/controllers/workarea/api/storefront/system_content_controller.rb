module Workarea
  module Api
    module Storefront
      class SystemContentController < Api::Storefront::ApplicationController
        before_action :cache_page

        def show
          @content = Workarea::Storefront::ContentViewModel.new(
            Content.for(params['id']),
            view_model_options
          )
        end
      end
    end
  end
end
