require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class RecommendationSettingsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Recommendation Settings'

        def test_and_document_show
          description 'Showing recommendation settings'
          route admin_api.product_recommendation_settings_path(':product_id')

          record_request do
            get admin_api.product_recommendation_settings_path(create_recommendations.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating recommendation settings'
          route admin_api.product_recommendation_settings_path(':product_id')

          record_request do
            patch admin_api.product_recommendation_settings_path(create_recommendations.id),
                  params: { recommendation_settings: { product_ids: ['foo'] } },
                  as: :json

            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
