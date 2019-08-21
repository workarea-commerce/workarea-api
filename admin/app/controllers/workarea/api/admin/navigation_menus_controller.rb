module Workarea
  module Api
    module Admin
      class NavigationMenusController < Admin::ApplicationController
        before_action :find_menu, except: [:index, :create]

        swagger_path '/navigation_menus' do
          operation :get do
            key :summary, 'All Navigation Menu'
            key :description, 'Returns all navigation menus from the system'
            key :operationId, 'listNavigationMenu'
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
              key :description, 'Navigation Menus'
              schema do
                key :type, :object
                property :navigation_menus do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Navigation::Menu'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Navigation Menu'
            key :description, 'Creates a new navigation menu'
            key :operationId, 'addNavigationMenu'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Navigation menu to add'
              key :required, true
              schema do
                key :type, :object
                property :navigation_menu do
                  key :'$ref', 'Workarea::Navigation::Menu'
                end
              end
            end

            response 201 do
              key :description, 'Navigation menu created'
              schema do
                key :type, :object
                property :navigation_menu do
                  key :'$ref', 'Workarea::Navigation::Menu'
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
                  key :'$ref', 'Workarea::Navigation::Menu'
                end
              end
            end
          end
        end

        def index
          @navigation_menus = Navigation::Menu
                    .all
                    .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                    .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                    .order_by(sort_field => sort_direction)
                    .page(params[:page])

          respond_with navigation_menus: @navigation_menus
        end

        def create
          @navigation_menu = Navigation::Menu.create!(params[:navigation_menu])
          respond_with(
            { navigation_menu: @navigation_menu },
            { status: :created,
            location: navigation_menu_path(@navigation_menu) }
          )
        end

        swagger_path '/navigation_menus/{id}' do
          operation :get do
            key :summary, 'Find Navigation Menu by ID'
            key :description, 'Returns a single navigation menu'
            key :operationId, 'showNavigationMenu'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of navigation menu to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Navigation menu details'
              schema do
                key :type, :object
                property :navigation_menu do
                  key :'$ref', 'Workarea::Navigation::Menu'
                end
              end
            end

            response 404 do
              key :description, 'Navigation menu not found'
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
            key :summary, 'Update a Navigation Menu'
            key :description, 'Updates attributes on a navigation menu'
            key :operationId, 'updateNavigationMenu'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of navigation menu to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :navigation_menu do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Navigation::Menu'
                end
              end
            end

            response 204 do
              key :description, 'Navigation menu updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Navigation::Menu'
                end
              end
            end

            response 404 do
              key :description, 'Navigation menu not found'
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
            key :summary, 'Remove a Navigation Menu'
            key :description, 'Remove a navigation menu'
            key :operationId, 'removeNavigationMenu'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of navigation menu to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Navigation menu removed successfully'
            end

            response 404 do
              key :description, 'Navigation menu not found'
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
          respond_with navigation_menu: @navigation_menu
        end

        def update
          @navigation_menu.update_attributes!(params[:navigation_menu])
          respond_with navigation_menu: @navigation_menu
        end

        def destroy
          @navigation_menu.destroy
          head :no_content
        end

        private

        def find_menu
          @navigation_menu = Navigation::Menu.find(params[:id])
        end
      end
    end
  end
end
