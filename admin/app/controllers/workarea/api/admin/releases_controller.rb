module Workarea
  module Api
    module Admin
      class ReleasesController < Admin::ApplicationController
        before_action :find_release, except: [:index, :create, :bulk]

        swagger_path '/releases' do
          operation :get do
            key :summary, 'All Releases'
            key :description, 'Returns all releases from the system'
            key :operationId, 'listReleases'
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
              key :description, 'Releases'
              schema do
                key :type, :object
                property :releases do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Release'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Release'
            key :description, 'Creates a new release.'
            key :operationId, 'addRelease'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Release to add'
              key :required, true
              schema do
                key :type, :object
                property :release do
                  key :'$ref', 'Workarea::Release'
                end
              end
            end

            response 201 do
              key :description, 'Release created'
              schema do
                key :type, :object
                property :release do
                  key :'$ref', 'Workarea::Release'
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
                  key :'$ref', 'Workarea::Release'
                end
              end
            end
          end
        end

        def index
          @releases = Release
                        .all
                        .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                        .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                        .order_by(sort_field => sort_direction)
                        .page(params[:page])
          respond_with releases: @releases
        end

        def create
          @release = Release.create!(params[:release])
          respond_with(
            { release: @release },
            { status: :created,
            location: release_path(@release) }
          )
        end

        swagger_path '/releases/{id}' do
          operation :get do
            key :summary, 'Find Release by ID'
            key :description, 'Returns a single release'
            key :operationId, 'showRelease'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of release to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Release details'
              schema do
                key :type, :object
                property :release do
                  key :'$ref', 'Workarea::Release'
                end
              end
            end

            response 404 do
              key :description, 'Release not found'
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
            key :summary, 'Update a Release'
            key :description, 'Updates attributes on a release'
            key :operationId, 'updateRelease'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of release to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :release do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Release'
                end
              end
            end

            response 204 do
              key :description, 'Release updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Release'
                end
              end
            end

            response 404 do
              key :description, 'Release not found'
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
            key :summary, 'Remove a Release'
            key :description, 'Remove a release'
            key :operationId, 'removeRelease'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of release to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Release removed successfully'
            end

            response 404 do
              key :description, 'Release not found'
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
          respond_with release: @release
        end

        def update
          @release.update_attributes!(params[:release])
          respond_with release: @release
        end

        swagger_path '/releases/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Releases'
            key :description, 'Creates new releases or updates existing ones in bulk.'
            key :operationId, 'upsertReleases'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of releases to upsert'
              key :required, true
              schema do
                key :type, :object
                property :releases do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Release'
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
            klass: Release,
            data: params[:releases].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @release.destroy
          head :no_content
        end

        private

        def find_release
          @release = Release.find(params[:id])
        end
      end
    end
  end
end
