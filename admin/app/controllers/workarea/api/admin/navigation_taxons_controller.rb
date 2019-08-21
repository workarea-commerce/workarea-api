module Workarea
  module Api
    module Admin
      class NavigationTaxonsController < Admin::ApplicationController
        before_action :find_taxon, except: [:index, :create, :bulk]

        swagger_path '/navigation_taxons' do
          operation :get do
            key :summary, 'All Navigation Taxons'
            key :description, 'Returns all navigation taxons from the system'
            key :operationId, 'listNavigationTaxons'
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
              key :description, 'Navigation taxons'
              schema do
                key :type, :object
                property :navigation_taxons do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Navigation::Taxon'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Navigation Taxon'
            key :description, 'Creates a new navigation taxon.'
            key :operationId, 'addNavigationTaxon'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Navigation taxon to add'
              key :required, true
              schema do
                key :type, :object
                property :navigation_taxon do
                  key :'$ref', 'Workarea::Navigation::Taxon'
                end
              end
            end

            response 201 do
              key :description, 'Navigation taxon created'
              schema do
                key :type, :object
                property :navigation_taxon do
                  key :'$ref', 'Workarea::Navigation::Taxon'
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
                  key :'$ref', 'Workarea::Navigation::Taxon'
                end
              end
            end
          end
        end

        def index
          @navigation_taxons = Navigation::Taxon
                    .all
                    .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                    .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                    .order_by(sort_field => sort_direction)
                    .page(params[:page])

          respond_with navigation_taxons: @navigation_taxons
        end

        def create
          @navigation_taxon = Navigation::Taxon.create!(params[:navigation_taxon])
          respond_with(
            { navigation_taxon: @navigation_taxon },
            { status: :created,
            location: navigation_taxon_path(@navigation_taxon) }
          )
        end

        swagger_path '/navigation_taxon/{id}' do
          operation :get do
            key :summary, 'Find Navigation Taxon by ID'
            key :description, 'Returns a single navigation taxon'
            key :operationId, 'showNavigationTaxon'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of navigation taxon to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Navigation taxon details'
              schema do
                key :type, :object
                property :navigation_taxon do
                  key :'$ref', 'Workarea::Navigation::Taxon'
                end
              end
            end

            response 404 do
              key :description, 'Navigation taxon not found'
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
            key :summary, 'Update a Navigation Taxon'
            key :description, 'Updates attributes on a navigation taxon'
            key :operationId, 'updateNavigationTaxon'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of navigation taxon to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :navigation_taxon do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Navigation::Taxon'
                end
              end
            end

            response 204 do
              key :description, 'Navigation taxon updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Navigation::Taxon'
                end
              end
            end

            response 404 do
              key :description, 'Navigation taxon not found'
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
            key :summary, 'Remove a Navigation Taxon'
            key :description, 'Remove a navigation taxon'
            key :operationId, 'removeNavigationTaxon'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of navigation taxon to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Navigation taxon removed successfully'
            end

            response 404 do
              key :description, 'Navigation taxon not found'
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
          respond_with navigation_taxon: @navigation_taxon
        end

        def update
          @navigation_taxon.update_attributes!(params[:navigation_taxon])
          respond_with navigation_taxon: @navigation_taxon
        end

        swagger_path '/navigation_taxons/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Navigation Taxons'
            key :description, 'Creates new navigation taxons or updates existing ones in bulk.'
            key :operationId, 'upsertNavigationTaxon'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of navigation taxons to upsert'
              key :required, true
              schema do
                key :type, :object
                property :navigation_taxons do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Navigation::Taxon'
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
            klass: Navigation::Taxon,
            data: params[:navigation_taxons].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @navigation_taxon.destroy
          head :no_content
        end

        private

        def find_taxon
          @navigation_taxon = Navigation::Taxon.find(params[:id])
        end
      end
    end
  end
end
