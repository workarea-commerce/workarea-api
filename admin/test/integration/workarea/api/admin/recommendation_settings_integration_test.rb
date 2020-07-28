require 'test_helper'

module Workarea
  module Api
    module Admin
      class RecommendationSettingsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_product

        def set_product
          @product = create_product
        end

        def create_recommendation_settings
          Recommendation::Settings.create!(id: @product.id)
        end

        def test_shows_recommendation_settings
          recommendation_settings = create_recommendation_settings
          get admin_api.product_recommendation_settings_path(@product.id)

          result = JSON.parse(response.body)['recommendation_settings']
          assert_equal(
            recommendation_settings,
            Recommendation::Settings.new(result)
          )
        end

        def test_updates_recommendation_settings
          recommendation_settings = create_recommendation_settings

          patch admin_api.product_recommendation_settings_path(@product.id),
            params: { recommendation_settings: { product_ids: ['foo'] } }

          assert_equal(['foo'], recommendation_settings.reload.product_ids)
        end

        def test_unpersisted_recommendation_settings
          get admin_api.product_recommendation_settings_path(@product.id)
          result = JSON.parse(response.body)['recommendation_settings']
          assert_equal(@product.id, result['_id'])
          assert_equal(0, Recommendation::Settings.count)

          patch admin_api.product_recommendation_settings_path(@product.id),
            params: { recommendation_settings: { product_ids: ['foo'] } }

          assert_equal(1, Recommendation::Settings.count)
          assert_equal(@product.id, Recommendation::Settings.first.id)
          assert_equal(['foo'], Recommendation::Settings.first.product_ids)
        end
      end
    end
  end
end
