module Workarea
  module Api
    module Admin
      class TaxRatesController < Admin::ApplicationController
        before_action :find_tax_category
        before_action :find_tax_rate, except: [:index, :create, :bulk]

        swagger_path '/tax_categories/{id}/rates' do
          operation :get do
            key :summary, 'All Tax Category Rates'
            key :description, 'Returns all rates for a tax category'
            key :operationId, 'listTaxCategoryRates'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'tax category ID'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Tax category rates'
              schema do
                key :type, :object
                property :rates do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Tax::Rate'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Tax Category Rate'
            key :description, 'Creates a new tax category rate.'
            key :operationId, 'addTaxCategoryRate'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'tax category ID'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Rate to add'
              key :required, true
              schema do
                key :type, :object
                property :rate do
                  key :'$ref', 'Workarea::Tax::Rate'
                end
              end
            end

            response 201 do
              key :description, 'Tax rate created'
              schema do
                key :type, :object
                property :rate do
                  key :'$ref', 'Workarea::Tax::Rate'
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
                  key :'$ref', 'Workarea::Tax::Rate'
                end
              end
            end
          end
        end

        def index
          @tax_rates = @tax_category
                          .rates
                          .order_by(sort_field => sort_direction)
                          .page(params[:page])

          respond_with rates: @tax_rates
        end

        def create
          @tax_rate = @tax_category.rates.create!(params[:rate])
          respond_with(
            { rate: @tax_rate },
            { status: :created,
            location: tax_category_rate_path(@tax_category, @tax_rate) }
          )
        end

        swagger_path '/tax_categories/{tax_category_id}/rates/{id}' do
          operation :patch do
            key :summary, 'Update a tax category rate'
            key :description, 'Updates attributes on a tax category rate'
            key :operationId, 'updateTaxCategoryRate'

            parameter do
              key :name, :tax_category_id
              key :in, :path
              key :description, 'ID of tax category to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of tax category rate to update'
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
                property :rate do
                  key :'$ref', 'Workarea::Tax::Rate'
                end
              end
            end

            response 204 do
              key :description, 'Tax category rate updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Tax::Rate'
                end
              end
            end

            response 404 do
              key :description, 'Tax category or rate not found'
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
            key :summary, 'Remove a Tax Category Rate'
            key :description, 'Remove a tax category rate'
            key :operationId, 'removeTaxCategoryRate'

            parameter do
              key :name, :tax_category_id
              key :in, :path
              key :description, 'ID of tax category'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of rate to update'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Tax category rate removed successfully'
            end

            response 404 do
              key :description, 'Tax category or rate not found'
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
          respond_with rate: @tax_rate
        end

        def update
          @tax_rate.update_attributes!(params[:rate])
          respond_with rate: @tax_rate
        end

        def destroy
          @tax_rate.destroy
          head :no_content
        end

        swagger_path '/tax_categories/{tax_category_id}/rates/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Rates'
            key :description, 'Creates new rates or updates existing ones in bulk.'
            key :operationId, 'upsertTaxCategoryRates'
            key :produces, ['application/json']

            parameter do
              key :name, :tax_category_id
              key :in, :path
              key :description, 'ID of tax category'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of rates to upsert'
              key :required, true
              schema do
                key :type, :object
                property :rates do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Tax::Rate'
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
          data = params[:rates].presence || []
          data.map!(&:to_h)
          data.map! { |a| a.merge(category_id: @tax_category.id) }

          @bulk = Api::Admin::BulkUpsert.create!(
            klass: Tax::Rate,
            data: data
          )

          head :no_content
        end


        private

        def find_tax_category
          @tax_category = Tax::Category.find(params[:tax_category_id])
        end

        def find_tax_rate
          @tax_rate = @tax_category.rates.find(params[:id])
        end
      end
    end
  end
end
