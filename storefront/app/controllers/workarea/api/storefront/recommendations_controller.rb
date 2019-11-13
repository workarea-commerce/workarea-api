module Workarea
  module Api
    module Storefront
      class RecommendationsController < Api::Storefront::ApplicationController
        before_action :assert_current_metrics_id

        def show
          @recommendations = Workarea::Storefront::PersonalizedRecommendationsViewModel.new(
            current_metrics,
            view_model_options
          )
        end
      end
    end
  end
end
