module Workarea
  module Api
    module Admin
      class PagesController < Admin::ApplicationController
        before_action :find_page, except: [:index, :create, :bulk]

        swagger_path '/pages' do
          operation :get do
            key :summary, 'All Pages'
            key :description, 'Returns all content pages from the system'
            key :operationId, 'listPages'
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

            parameter :updated_at_starts_at
            parameter :updated_at_ends_at
            parameter :created_at_starts_at
            parameter :created_at_ends_at

            response 200 do
              key :description, 'Pages'
              schema do
                key :type, :object
                property :pages do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Content::Page'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Page'
            key :description, 'Creates a new content page'
            key :operationId, 'addPage'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Page to add'
              key :required, true
              schema do
                key :type, :object
                property :page do
                  key :'$ref', 'Workarea::Content::Page'
                end
              end
            end

            response 201 do
              key :description, 'Page created'
              schema do
                key :type, :object
                property :page do
                  key :'$ref', 'Workarea::Content::Page'
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
                  key :'$ref', 'Workarea::Content::Page'
                end
              end
            end
          end
        end

        def index
          @pages = Content::Page
                      .all
                      .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                      .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                      .order_by(sort_field => sort_direction)
                      .page(params[:page])

          respond_with pages: @pages
        end

        def create
          @page = Content::Page.create!(params[:page])
          respond_with(
            { page: @page },
            { status: :created,
            location: page_path(@page.id) }
          )
        end

        swagger_path '/pages/{id}' do
          operation :get do
            key :summary, 'Find Page by ID'
            key :description, 'Returns a single content page'
            key :operationId, 'showPage'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of content page to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Page details'
              schema do
                key :type, :object
                property :page do
                  key :'$ref', 'Workarea::Content::Page'
                end
              end
            end

            response 404 do
              key :description, 'Page not found'
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
            key :summary, 'Update a Page'
            key :description, 'Updates attributes on a page'
            key :operationId, 'updatePage'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of page to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :page do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Content::Page'
                end
              end
            end

            response 204 do
              key :description, 'Page updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Content::Page'
                end
              end
            end

            response 404 do
              key :description, 'Page not found'
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
            key :summary, 'Remove a Page'
            key :description, 'Remove a page'
            key :operationId, 'removePage'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of page to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Page removed successfully'
            end

            response 404 do
              key :description, 'Page not found'
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
          respond_with page: @page
        end

        def update
          @page.update_attributes!(params[:page])
          respond_with page: @page
        end

        swagger_path '/pages/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Pages'
            key :description, 'Creates new pages or updates existing ones in bulk.'
            key :operationId, 'upsertPages'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of pages to upsert'
              key :required, true
              schema do
                key :type, :object
                property :pages do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Content::Page'
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
            klass: Content::Page,
            data: params[:pages].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @page.destroy
          head :no_content
        end

        private

        def find_page
          @page = Content::Page.find(params[:id])
        end
      end
    end
  end
end
