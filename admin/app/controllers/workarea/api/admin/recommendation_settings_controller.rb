module Workarea
  module Api
    module Admin
      class RecommendationSettingsController < Admin::ApplicationController
        before_action :find_recommendation_settings

        swagger_path '/products/{product_id}/recommendation_settings' do
          operation :get do
            key :summary, 'Find Recommendation Settings by Product ID'
            key :description, 'Returns recommendation settings for a product'
            key :operationId, 'showProductRecommendationSettings'

            parameter do
              key :name, :product_id
              key :in, :path
              key :description, 'ID of product to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Recommendation settings'
              schema do
                key :type, :object
                property :recommendation_settings do
                  key :'$ref', 'Workarea::Recommendation::Settings'
                end
              end
            end

            response 404 do
              key :description, 'Product or recommendation settings not found'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :params do
                  key :type, :object
                  key :additionalProperties, true
                end
              end
            end
          end

          operation :patch do
            key :summary, 'Update product recommendation settings'
            key :description, 'Updates attributes on recommendation settings for a product'
            key :operationId, 'updateProductRecommendationSettings'

            parameter do
              key :name, :product_id
              key :in, :path
              key :description, 'ID of product'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'New attributes'
              key :required, true
              schema do
                key :type, :object
                property :recommendation_settings do
                  key :'$ref', 'Workarea::Recommendation::Settings'
                end
              end
            end

            response 204 do
              key :description, 'Recommendation settings updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Recommendation::Settings'
                end
              end
            end

            response 404 do
              key :description, 'Product not found'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :params do
                  key :type, :object
                  key :additionalProperties, true
                end
              end
            end
          end
        end

        def show
          respond_with recommendation_settings: @recommendation_settings
        end

        def update
          @recommendation_settings.update_attributes!(params[:recommendation_settings])
          respond_with recommendation_settings: @recommendation_settings
        end

        private

        def find_recommendation_settings
          @recommendation_settings = Recommendation::Settings.find_or_initialize_by(id: params[:product_id])
        end
      end
    end
  end
end
