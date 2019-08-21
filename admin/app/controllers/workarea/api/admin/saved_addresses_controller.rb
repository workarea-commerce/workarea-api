module Workarea
  module Api
    module Admin
      class SavedAddressesController < Admin::ApplicationController
        before_action :find_user
        before_action :find_saved_address, except: [:index, :create]

        swagger_path '/users/{id}/saved_addresses' do
          operation :get do
            key :summary, 'All Saved Addresses'
            key :description, 'Returns all saved addresses for a user'
            key :operationId, 'listSavedAddresses'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'user ID'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Saved addresses'
              schema do
                key :type, :object
                property :saved_addresses do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::User::SavedAddress'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Saved Address'
            key :description, 'Creates a new saved address'
            key :operationId, 'addSavedAddress'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'product ID'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Saved address to add'
              key :required, true
              schema do
                key :type, :object
                property :saved_address do
                  key :'$ref', 'Workarea::User::SavedAddress'
                end
              end
            end

            response 201 do
              key :description, 'Saved address created'
              schema do
                key :type, :object
                property :saved_address do
                  key :'$ref', 'Workarea::User::SavedAddress'
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
                  key :'$ref', 'Workarea::User::SavedAddress'
                end
              end
            end
          end
        end

        def index
          respond_with saved_addresses: @user.addresses
        end

        def create
          @saved_address = @user.addresses.create!(params[:saved_address])
          respond_with(
            { saved_address: @saved_address },
            { status: :created,
            location: user_saved_addresses_path(@user) }
          )
        end

        swagger_path '/users/{user_id}/saved_addresses/{id}' do
          operation :patch do
            key :summary, 'Update a saved address'
            key :description, 'Updates attributes on a saved address'
            key :operationId, 'updateSavedAddress'

            parameter do
              key :name, :user_id
              key :in, :path
              key :description, 'ID of user'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of saved address to update'
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
                property :saved_address do
                  key :'$ref', 'Workarea::User::SavedAddress'
                end
              end
            end

            response 204 do
              key :description, 'Saved address updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::User::SavedAddress'
                end
              end
            end

            response 404 do
              key :description, 'User or saved address not found'
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
            key :summary, 'Remove a Saved Address'
            key :description, 'Remove a saved address'
            key :operationId, 'removeSavedAddress'

            parameter do
              key :name, :user_id
              key :in, :path
              key :description, 'ID of user'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of saved address to update'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Saved address removed successfully'
            end

            response 404 do
              key :description, 'User or saved address not found'
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
          @saved_address.update_attributes!(params[:saved_address])
          respond_with saved_address: @saved_address
        end

        def destroy
          @saved_address.destroy
          head :no_content
        end

        private

        def find_user
          @user = User.find(params[:user_id])
        end

        def find_saved_address
          @saved_address = @user.addresses.find(params[:id])
        end
      end
    end
  end
end
