module Workarea
  module Api
    module Admin
      class CategoryProductRulesController < Admin::ApplicationController
        before_action :find_category
        before_action :find_product_rule, except: [:index, :create]

        swagger_path '/categories/{id}/product_rules' do
          operation :get do
            key :summary, 'All Category Product Rules'
            key :description, 'Returns all product rules for a category'
            key :operationId, 'listCategoryProductRules'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'category ID'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Category product rules'
              schema do
                key :type, :object
                property :product_rules do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::ProductRule'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Category Product Rule'
            key :description, 'Creates a new category product rule.'
            key :operationId, 'addCategoryProductRule'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'category ID'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Rule to add'
              key :required, true
              schema do
                key :type, :object
                property :product_rule do
                  key :'$ref', 'Workarea::ProductRule'
                end
              end
            end

            response 201 do
              key :description, 'Product rule created'
              schema do
                key :type, :object
                property :product_rule do
                  key :'$ref', 'Workarea::ProductRule'
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
                  key :'$ref', 'Workarea::ProductRule'
                end
              end
            end
          end
        end

        def index
          respond_with product_rules: @category.product_rules
        end

        def create
          @product_rule = @category.product_rules.create!(params[:product_rule])
          respond_with(
            { product_rule: @product_rule },
            { status: :created,
            location: category_product_rules_path(@category.id) }
          )
        end

        swagger_path '/categories/{category_id}/product_rules/{id}' do
          operation :patch do
            key :summary, 'Update a category product rule'
            key :description, 'Updates attributes on a category product rule'
            key :operationId, 'updateCategoryProductRule'

            parameter do
              key :name, :category_id
              key :in, :path
              key :description, 'ID of category'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of category product rule to update'
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
                property :product_rule do
                  key :'$ref', 'Workarea::ProductRule'
                end
              end
            end

            response 204 do
              key :description, 'Category product rule updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::ProductRule'
                end
              end
            end

            response 404 do
              key :description, 'Category or product rule not found'
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
            key :summary, 'Remove a Category Product Rule'
            key :description, 'Remove a category product rule'
            key :operationId, 'removeCategoryProductRule'

            parameter do
              key :name, :category_id
              key :in, :path
              key :description, 'ID of category'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of category product rule to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Category product rule removed successfully'
            end

            response 404 do
              key :description, 'Category or product rule not found'
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

        def update
          @product_rule.update_attributes!(params[:product_rule])
          respond_with product_rule: @product_rule
        end

        def destroy
          @product_rule.destroy
          head :no_content
        end

        private

        def find_category
          @category = Catalog::Category.find(params[:category_id])
        end

        def find_product_rule
          @product_rule = @category.product_rules.find(params[:id])
        end
      end
    end
  end
end
