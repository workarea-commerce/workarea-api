module Workarea
  module Api
    module Admin
      class ContentAssetsController < Admin::ApplicationController
        before_action :find_asset, except: [:index, :create, :bulk]

        swagger_path '/content_assets' do
          operation :get do
            key :summary, 'All Content Assets'
            key :description, 'Returns all content assets from the system'
            key :operationId, 'listContentAssets'
            key :produces, ['application/json']

            parameter do
              key :name, :page
              key :in, :query
              key :description, 'Current page'
              key :required, false
              key :type, :integer
              key :default, 1
            end
            parameter do
              key :name, :sort_by
              key :in, :query
              key :description, 'Field on which to sort (see responses for possible values)'
              key :required, false
              key :type, :string
              key :default, 'created_at'
            end
            parameter do
              key :name, :sort_direction
              key :in, :query
              key :description, 'Direction for sort by'
              key :type, :string
              key :enum, %w(asc desc)
              key :default, 'desc'
            end

            response 200 do
              key :description, 'Content assets'
              schema do
                key :type, :object
                property :assets do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Content::Asset'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Content Asset'
            key :description, 'Creates a new content asset.'
            key :operationId, 'addContentAsset'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Content asset to add'
              key :required, true
              schema do
                key :type, :object
                property :asset do
                  key :'$ref', 'Workarea::Content::Asset'
                end
              end
            end

            response 201 do
              key :description, 'Content asset created'
              schema do
                key :type, :object
                property :asset do
                  key :'$ref', 'Workarea::Content::Asset'
                end
              end
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Content::Asset'
                end
              end
            end
          end
        end

        def index
          @assets = Content::Asset
                      .all
                      .order_by(sort_field => sort_direction)
                      .page(params[:page])

          respond_with assets: @assets
        end

        def create
          @asset = Content::Asset.create!(params[:asset])
          respond_with(
            { asset: @asset },
            { status: :created,
            location: content_asset_path(@asset) }
          )
        end

        swagger_path '/content_assets/{id}' do
          operation :get do
            key :summary, 'Find Content Asset by ID'
            key :description, 'Returns a single content asset'
            key :operationId, 'showContentAsset'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of content asset to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Content asset details'
              schema do
                key :'$ref', 'Workarea::Content::Asset'
              end
            end

            response 404 do
              key :description, 'Content asset not found'
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
            key :summary, 'Update a Content Asset'
            key :description, 'Updates attributes on a content asset'
            key :operationId, 'updateContentAsset'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of content asset to update'
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
                property :asset do
                  key :'$ref', 'Workarea::Content::Asset'
                end
              end
            end

            response 204 do
              key :description, 'Content asset updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Content::Asset'
                end
              end
            end

            response 404 do
              key :description, 'Content asset not found'
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

          operation :delete do
            key :summary, 'Remove a Content Asset'
            key :description, 'Remove a content asset'
            key :operationId, 'removeContentAsset'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of content asset to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Content asset removed successfully'
            end

            response 404 do
              key :description, 'Content asset not found'
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
          respond_with asset: @asset
        end

        def update
          @asset.update_attributes!(params[:asset])
          respond_with asset: @asset
        end

        swagger_path '/content_assets/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Content Assets'
            key :description, 'Creates new content assets or updates existing ones in bulk.'
            key :operationId, 'upsertContentAssets'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of content assets to upsert'
              key :required, true
              schema do
                key :type, :array
                items do
                  key :'$ref', 'Workarea::Content::Asset'
                end
              end
            end

            response 204 do
              key :description, 'Upsert received'
            end
          end
        end

        def bulk
          @bulk = Api::Admin::BulkUpsert.create!(
            klass: Content::Asset,
            data: params[:assets].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @asset.destroy
          head :no_content
        end

        private

        def find_asset
          @asset = Content::Asset.find(params[:id])
        end
      end
    end
  end
end
