module Workarea
  module Api
    module Admin
      class ContentController < Admin::ApplicationController
        before_action :find_content, except: [:index, :create, :bulk]

        swagger_path '/content' do
          operation :get do
            key :summary, 'All Content'
            key :description, 'Returns all content from the system'
            key :operationId, 'listContent'
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
              key :description, 'Content'
              schema do
                key :type, :object
                property :content do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Content'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Content'
            key :description, 'Creates a new content.'
            key :operationId, 'addContent'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Content to add'
              key :required, true
              schema do
                key :type, :object
                property :content do
                  key :'$ref', 'Workarea::Content'
                end
              end
            end

            response 201 do
              key :description, 'Content created'
              schema do
                key :type, :object
                property :content do
                  key :'$ref', 'Workarea::Content'
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
                  key :'$ref', 'Workarea::Content'
                end
              end
            end
          end
        end

        def index
          @content = Content
                        .all
                        .order_by(sort_field => sort_direction)
                        .page(params[:page])

          respond_with content: @content
        end

        def create
          @content = Content.create!(params[:content])
          respond_with(
            { content: @content },
            { status: :created,
            location: content_path(@content) }
          )
        end

        swagger_path '/content/{id}' do
          operation :get do
            key :summary, 'Find Content by ID'
            key :description, 'Returns one content'
            key :operationId, 'showContent'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of content to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Content details'
              schema do
                key :type, :object
                property :content do
                  key :'$ref', 'Workarea::Content'
                end
              end
            end

            response 404 do
              key :description, 'Content not found'
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
            key :summary, 'Update Content'
            key :description, 'Updates attributes on content'
            key :operationId, 'updateContent'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of content to update'
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
                property :content do
                  key :'$ref', 'Workarea::Content'
                end
              end
            end

            response 204 do
              key :description, 'Content updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Content'
                end
              end
            end

            response 404 do
              key :description, 'Content not found'
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
          respond_with content: @content
        end

        def update
          @content.update_attributes!(params[:content])
          respond_with content: @content
        end

        swagger_path '/content/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Content'
            key :description, 'Creates new content or updates existing ones in bulk.'
            key :operationId, 'upsertContent'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of content to upsert'
              key :required, true
              schema do
                key :type, :object
                property :content do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Content'
                  end
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
            klass: Content,
            data: params[:content].map(&:to_h)
          )

          head :no_content
        end

        private

        def find_content
          @content = Content.find(params[:id])
        end
      end
    end
  end
end
