module Workarea
  module Api
    module Admin
      class TaxCategoriesController < Admin::ApplicationController
        before_action :find_tax_category, except: [:index, :create, :bulk]

        swagger_path '/tax_categories' do
          operation :get do
            key :summary, 'All Tax Categories'
            key :description, 'Returns all tax categories'
            key :operationId, 'listTaxCategories'
            key :produces, ['application/json']

            response 200 do
              key :description, 'Tax categories'
              schema do
                key :type, :object
                property :tax_categories do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Tax::Category'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create a tax category'
            key :description, 'Creates a new taxable category.'
            key :operationId, 'addTaxCategory'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Tax Category to add'
              key :required, true
              schema do
                key :type, :object
                property :tax_category do
                  key :'$ref', 'Workarea::Tax::Category'
                end
              end
            end

            response 201 do
              key :description, 'Tax category created'
              schema do
                key :type, :object
                property :tax_category do
                  key :'$ref', 'Workarea::Tax::Category'
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
                  key :'$ref', 'Workarea::Tax::Category'
                end
              end
            end
          end
        end

        def index
          @tax_categories = Tax::Category
                                .all
                                .order_by(sort_field => sort_direction)
                                .page(params[:page])

          respond_with tax_categories: @tax_categories
        end

        def create
          @tax_category = Tax::Category.create!(params[:tax_category])
          respond_with(
            { tax_category: @tax_category },
            { status: :created,
            location: tax_category_path(@tax_category) }
          )
        end

        swagger_path '/tax_categories/{id}' do
          operation :patch do
            key :summary, 'Update a tax category'
            key :description, 'Updates attributes on a tax category'
            key :operationId, 'updateTaxCategory'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of tax category to update'
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
                property :tax_category do
                  key :'$ref', 'Workarea::Tax::Category'
                end
              end
            end

            response 204 do
              key :description, 'Tax category updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Tax::Category'
                end
              end
            end

            response 404 do
              key :description, 'Tax category not found'
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
            key :summary, 'Remove a Tax Category'
            key :description, 'Remove a tax category'
            key :operationId, 'removeTaxCategory'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of tax category'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Tax category removed successfully'
            end

            response 404 do
              key :description, 'Tax category not found'
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
          respond_with tax_category: @tax_category
        end

        def update
          @tax_category.update_attributes!(params[:tax_category])
          respond_with tax_category: @tax_category
        end

        def destroy
          @tax_category.destroy
          head :no_content
        end

        swagger_path '/tax_categories/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert tax categories'
            key :description, 'Creates new tax categories or updates existing ones in bulk.'
            key :operationId, 'upsertTaxCategory'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of tax categories to upsert'
              key :required, true
              schema do
                key :type, :object
                property :tax_categories do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Tax::Category'
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
            klass: Tax::Category,
            data: params[:tax_categories].map(&:to_h)
          )

          head :no_content
        end

        private

        def find_tax_category
          @tax_category = Tax::Category.find(params[:id])
        end
      end
    end
  end
end
