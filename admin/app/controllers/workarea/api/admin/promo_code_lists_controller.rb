module Workarea
  module Api
    module Admin
      class PromoCodeListsController < Admin::ApplicationController
        before_action :find_promo_code_list, except: [:index, :create, :bulk]

        swagger_path '/promo_code_lists' do
          operation :get do
            key :summary, 'All Promo Code Lists'
            key :description, 'Returns all promo code lists from the system'
            key :operationId, 'listPromoCodeLists'
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
              key :description, 'Promo code lists'
              schema do
                key :type, :object
                property :promo_code_lists do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Pricing::Discount::CodeList'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Promo Code List'
            key :description, 'Creates a new promo code list.'
            key :operationId, 'addPromoCodeList'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Promo code list to add'
              key :required, true
              schema do
                key :type, :object
                property :promo_code_list do
                  key :'$ref', 'Workarea::Pricing::Discount::CodeList'
                end
              end
            end

            response 201 do
              key :description, 'Promo code list created'
              schema do
                key :type, :object
                property :promo_code_list do
                  key :'$ref', 'Workarea::Pricing::Discount::CodeList'
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
                  key :'$ref', 'Workarea::Pricing::Discount::CodeList'
                end
              end
            end
          end
        end

        def index
          @promo_code_lists = Pricing::Discount::CodeList
                                .all
                                .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                                .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                                .order_by(sort_field => sort_direction)
                                .page(params[:page])

          respond_with promo_code_lists: @promo_code_lists
        end

        def create
          @promo_code_list = Pricing::Discount::CodeList.create!(params[:promo_code_list])
          respond_with(
            { promo_code_list: @promo_code_list },
            { status: :created,
            location: promo_code_list_path(@promo_code_list) }
          )
        end

        swagger_path '/promo_code_lists/{id}' do
          operation :get do
            key :summary, 'Find Promo Code List by ID'
            key :description, 'Returns a single promo code list'
            key :operationId, 'showPromoCodeList'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of promo code list to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Promo code list details'
              schema do
                key :type, :object
                property :promo_code_list do
                  key :'$ref', 'Workarea::Pricing::Discount::CodeList'
                end
              end
            end

            response 404 do
              key :description, 'Promo code list not found'
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
            key :summary, 'Update a Promo Code List'
            key :description, 'Updates attributes on a promo code list'
            key :operationId, 'updatePromoCodeList'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of promo code list to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :promo_code_list do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Pricing::Discount::CodeList'
                end
              end
            end

            response 204 do
              key :description, 'Promo code list updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Pricing::Discount::CodeList'
                end
              end
            end

            response 404 do
              key :description, 'Promo code list not found'
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
            key :summary, 'Remove a Promo Code List'
            key :description, 'Remove a promo code list'
            key :operationId, 'removePromoCodeList'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of promo code list to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Promo code list removed successfully'
            end

            response 404 do
              key :description, 'Promo code list not found'
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
          respond_with promo_code_list: @promo_code_list
        end

        def update
          @promo_code_list.update_attributes!(params[:promo_code_list])
          respond_with promo_code_list: @promo_code_list
        end

        swagger_path '/promo_code_lists/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Promo Code Lists'
            key :description, 'Creates new promo code lists or updates existing ones in bulk.'
            key :operationId, 'upsertPromoCodeLists'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of promo code lists to upsert'
              key :required, true
              schema do
                key :type, :object
                property :promo_code_lists do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Pricing::Discount::CodeList'
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
            klass: Pricing::Discount::CodeList,
            data: params[:promo_code_lists].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @promo_code_list.destroy
          head :no_content
        end

        private

        def find_promo_code_list
          @promo_code_list = Pricing::Discount::CodeList.find(params[:id])
        end
      end
    end
  end
end
