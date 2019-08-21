module Workarea
  module Api
    module Admin
      class DiscountsController < Admin::ApplicationController
        before_action :find_discount, except: [:index, :create, :bulk]

        swagger_path '/discounts' do
          operation :get do
            key :summary, 'All Discounts'
            key :description, 'Returns all discounts from the system'
            key :operationId, 'listDiscounts'
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
              key :description, 'Discounts'
              schema do
                key :type, :object
                property :discounts do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Pricing::Discount'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Discount'
            key :description, 'Creates a new discount.'
            key :operationId, 'addDiscount'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Discount to add'
              key :required, true
              schema do
                key :type, :object
                property :discount do
                  key :'$ref', 'Workarea::Pricing::Discount'
                end
              end
            end

            response 201 do
              key :description, 'Discount created'
              schema do
                key :type, :object
                property :discount do
                  key :'$ref', 'Workarea::Pricing::Discount'
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
                  key :'$ref', 'Workarea::Pricing::Discount'
                end
              end
            end
          end
        end

        def index
          @discounts = Pricing::Discount
                          .all
                          .order_by(sort_field => sort_direction)
                          .page(params[:page])

          respond_with discounts: @discounts
        end

        def create
          attrs = params[:discount].presence || {}

          @discount = NewDiscount.new_discount(attrs[:type], attrs.except(:type))
          @discount.save!

          respond_with(
            { discount: @discount },
            { status: :created,
            location: discount_path(@discount) }
          )
        end

        swagger_path '/discounts/{id}' do
          operation :get do
            key :summary, 'Find Discount by ID'
            key :description, 'Returns a single discount'
            key :operationId, 'showDiscount'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of discount to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Discount details'
              schema do
                key :type, :object
                property :discount do
                  key :'$ref', 'Workarea::Pricing::Discount'
                end
              end
            end

            response 404 do
              key :description, 'Discount not found'
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
            key :summary, 'Update a Discount'
            key :description, 'Updates attributes on a discount'
            key :operationId, 'updateDiscount'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of discount to update'
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
                property :discount do
                  key :'$ref', 'Workarea::Pricing::Discount'
                end
              end
            end

            response 204 do
              key :description, 'Discount updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Pricing::Discount'
                end
              end
            end

            response 404 do
              key :description, 'Discount not found'
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
            key :summary, 'Remove a Discount'
            key :description, 'Remove a discount'
            key :operationId, 'removeDiscount'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of discount to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Discount removed successfully'
            end

            response 404 do
              key :description, 'Discount not found'
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
          respond_with discount: @discount
        end

        def update
          @discount.update_attributes!(params[:discount])
          respond_with discount: @discount
        end

        def destroy
          @discount.destroy
          head :no_content
        end

        private

        def find_discount
          @discount = Pricing::Discount.find(params[:id])
        end
      end
    end
  end
end
