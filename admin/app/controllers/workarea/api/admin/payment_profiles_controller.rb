module Workarea
  module Api
    module Admin
      class PaymentProfilesController < Admin::ApplicationController
        before_action :find_payment_profile, except: [:index, :create, :bulk]

        swagger_path '/payment_profiles' do
          operation :get do
            key :summary, 'All Payment Profiles'
            key :description, 'Returns all payment profiles from the system'
            key :operationId, 'listPaymentProfiles'
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
              key :description, 'Payment profiles'
              schema do
                key :type, :object
                property :payment_profiles do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Payment::Profile'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Payment Profile'
            key :description, 'Creates a new payment profile'
            key :operationId, 'addPaymentProfile'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Payment profile to add'
              key :required, true
              schema do
                key :type, :object
                property :payment_profile do
                  key :'$ref', 'Workarea::Payment::Profile'
                end
              end
            end

            response 201 do
              key :description, 'Payment profile created'
              schema do
                key :type, :object
                property :payment_profile do
                  key :'$ref', 'Workarea::Payment::Profile'
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
                  key :'$ref', 'Workarea::Payment::Profile'
                end
              end
            end
          end
        end

        def index
          @payment_profiles = Payment::Profile
                                .all
                                .order_by(sort_field => sort_direction)
                                .page(params[:page])

          respond_with payment_profiles: @payment_profiles
        end

        def create
          @payment_profile = Payment::Profile.create!(params[:payment_profile])
          respond_with(
            { payment_profile: @payment_profile },
            { status: :created,
            location: payment_profile_path(@payment_profile) }
          )
        end

        swagger_path '/payment_profiles/{id}' do
          operation :get do
            key :summary, 'Find Payment Profile by ID'
            key :description, 'Returns a single payment profile'
            key :operationId, 'showPaymentProfile'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of payment profile to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Payment profile details'
              schema do
                key :type, :object
                property :payment_profile do
                  key :'$ref', 'Workarea::Payment::Profile'
                end
              end
            end

            response 404 do
              key :description, 'Payment profile not found'
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
            key :summary, 'Update a Payment Profile'
            key :description, 'Updates attributes on a payment profile'
            key :operationId, 'updatePaymentProfile'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of payment profile to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :payment_profile do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Payment::Profile'
                end
              end
            end

            response 204 do
              key :description, 'Payment profile updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Payment::Profile'
                end
              end
            end

            response 404 do
              key :description, 'Payment profile not found'
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
            key :summary, 'Remove a Payment Profile'
            key :description, 'Remove a payment profile'
            key :operationId, 'removePaymentProfile'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of payment profile to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Payment profile removed successfully'
            end

            response 404 do
              key :description, 'Payment profile not found'
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
          respond_with payment_profile: @payment_profile
        end

        def update
          @payment_profile.update_attributes!(params[:payment_profile])
          respond_with payment_profile: @payment_profile
        end

        swagger_path '/payment_profiles/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Payment Profile'
            key :description, 'Creates new payment profiles or updates existing ones in bulk.'
            key :operationId, 'upsertPaymentProfiles'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of payment profiles to upsert'
              key :required, true
              schema do
                key :type, :object
                property :payment_profiles do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Payment::Profile'
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
            klass: Payment::Profile,
            data: params[:payment_profiles].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @payment_profile.destroy
          head :no_content
        end

        private

        def find_payment_profile
          @payment_profile = Payment::Profile.find(params[:id])
        end
      end
    end
  end
end
