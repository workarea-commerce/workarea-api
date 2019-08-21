module Workarea
  module Api
    module Admin
      class RedirectsController < Admin::ApplicationController
        before_action :find_redirect, except: [:index, :create, :bulk]

        swagger_path '/redirects' do
          operation :get do
            key :summary, 'All Redirects'
            key :description, 'Returns all redirects from the system'
            key :operationId, 'listRedirects'
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
              key :description, 'Redirects'
              schema do
                key :type, :object
                property :redirects do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Navigation::Redirect'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Redirect'
            key :description, 'Creates a new redirect.'
            key :operationId, 'addRedirect'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Redirect to add'
              key :required, true
              schema do
                key :type, :object
                property :redirect do
                  key :'$ref', 'Workarea::Navigation::Redirect'
                end
              end
            end

            response 201 do
              key :description, 'Redirect created'
              schema do
                key :type, :object
                property :redirect do
                  key :'$ref', 'Workarea::Navigation::Redirect'
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
                  key :'$ref', 'Workarea::Navigation::Redirect'
                end
              end
            end
          end
        end

        def index
          @redirects = Navigation::Redirect
                        .all
                        .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                        .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                        .order_by(sort_field => sort_direction)
                        .page(params[:page])

          respond_with redirects: @redirects
        end

        def create
          @redirect = Navigation::Redirect.create!(params[:redirect])
          respond_with(
            { redirect: @redirect },
            { status: :created,
            location: redirect_path(@redirect) }
          )
        end

        swagger_path '/redirects/{id}' do
          operation :get do
            key :summary, 'Find Redirect by ID'
            key :description, 'Returns a single redirect'
            key :operationId, 'showRedirect'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of redirect to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Redirect details'
              schema do
                key :type, :object
                property :redirect do
                  key :'$ref', 'Workarea::Navigation::Redirect'
                end
              end
            end

            response 404 do
              key :description, 'Redirect not found'
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
            key :summary, 'Update a Redirect'
            key :description, 'Updates attributes on a redirect'
            key :operationId, 'updateRedirect'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of redirect to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :redirect do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Navigation::Redirect'
                end
              end
            end

            response 204 do
              key :description, 'Redirect updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Navigation::Redirect'
                end
              end
            end

            response 404 do
              key :description, 'Redirect not found'
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
            key :summary, 'Remove a Redirect'
            key :description, 'Remove a redirect'
            key :operationId, 'removeRedirect'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of redirect to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Redirect removed successfully'
            end

            response 404 do
              key :description, 'Redirect not found'
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
          respond_with redirect: @redirect
        end

        def update
          @redirect.update_attributes!(params[:redirect])
          respond_with redirect: @redirect
        end

        swagger_path '/redirects/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Redirects'
            key :description, 'Creates new redirects or updates existing ones in bulk.'
            key :operationId, 'upsertRedirects'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of redirects to upsert'
              key :required, true
              schema do
                key :type, :object
                property :redirects do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Navigation::Redirect'
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
            klass: Navigation::Redirect,
            data: params[:redirects].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @redirect.destroy
          head :no_content
        end

        private

        def find_redirect
          @redirect = Navigation::Redirect.find(params[:id])
        end
      end
    end
  end
end
