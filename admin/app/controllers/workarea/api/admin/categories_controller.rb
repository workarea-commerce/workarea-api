module Workarea
  module Api
    module Admin
      class CategoriesController < Admin::ApplicationController
        before_action :find_category, except: [:index, :create, :bulk]

        swagger_path '/categories' do
          operation :get do
            key :summary, 'All Categories'
            key :description, 'Returns all categories from the system'
            key :operationId, 'listCategories'
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
              key :description, 'Categories'
              schema do
                key :type, :object
                property :categories do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Catalog::Category'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Category'
            key :description, 'Creates a new category.'
            key :operationId, 'addCategory'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Category to add'
              key :required, true
              schema do
                key :type, :object
                property :category do
                  key :'$ref', 'Workarea::Catalog::Category'
                end
              end
            end

            response 201 do
              key :description, 'Category created'
              schema do
                key :type, :object
                property :category do
                  key :'$ref', 'Workarea::Catalog::Category'
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
                  key :'$ref', 'Workarea::Catalog::Category'
                end
              end
            end
          end
        end

        def index
          @categories = Catalog::Category
                          .all
                          .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                          .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                          .order_by(sort_field => sort_direction)
                          .page(params[:page])

          respond_with categories: @categories
        end

        def create
          @category = Catalog::Category.create!(params[:category])
          respond_with(
            { category: @category },
            { status: :created,
            location: category_path(@category.id) }
          )
        end

        swagger_path '/categories/{id}' do
          operation :get do
            key :summary, 'Find Category by ID'
            key :description, 'Returns a single category'
            key :operationId, 'showCategory'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of category to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Category details'
              schema do
                key :type, :object
                property :category do
                  key :'$ref', 'Workarea::Catalog::Category'
                end
              end
            end

            response 404 do
              key :description, 'Category not found'
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
            key :summary, 'Update a Category'
            key :description, 'Updates attributes on a category'
            key :operationId, 'updateCategory'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of category to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :category do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Catalog::Category'
                end
              end
            end

            response 204 do
              key :description, 'Category updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Catalog::Category'
                end
              end
            end

            response 404 do
              key :description, 'Category not found'
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
            key :summary, 'Remove a Category'
            key :description, 'Remove a category'
            key :operationId, 'removeCategory'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of category to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Category removed successfully'
            end

            response 404 do
              key :description, 'Category not found'
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
          respond_with category: @category
        end

        def update
          @category.update_attributes!(params[:category])
          respond_with category: @category
        end

        swagger_path '/categories/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Categories'
            key :description, 'Creates new categories or updates existing ones in bulk.'
            key :operationId, 'upsertCategories'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of categories to upsert'
              key :required, true
              schema do
                key :type, :object
                property :categories do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Catalog::Category'
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
            klass: Catalog::Category,
            data: params[:categories].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @category.destroy
          head :no_content
        end

        private

        def find_category
          @category = Catalog::Category.find(params[:id])
        end
      end
    end
  end
end
