module Workarea
  module Api
    module Admin
      class SavedCreditCardsController < Admin::ApplicationController
        before_action :find_payment_profile
        before_action :find_saved_credit_card, except: [:index, :create, :bulk]

        swagger_path '/payment_profiles/{id}/saved_credit_cards' do
          operation :get do
            key :summary, 'All Saved Credit Cards'
            key :description, 'Returns all saved credit cards for a payment profile'
            key :operationId, 'listSavedCreditCards'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'payment profile ID'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Saved credit cards'
              schema do
                key :type, :object
                property :saved_credit_cards do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Payment::SavedCreditCard'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Saved Credit Card'
            key :description, 'Creates a new saved credit card'
            key :operationId, 'addSavedCreditCard'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'saved credit card ID'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Saved credit card to add'
              key :required, true
              schema do
                key :type, :object
                property :saved_credit_card do
                  key :'$ref', 'Workarea::Payment::SavedCreditCard'
                end
              end
            end

            response 201 do
              key :description, 'Saved credit card created'
              schema do
                key :type, :object
                property :saved_credit_card do
                  key :'$ref', 'Workarea::Payment::SavedCreditCard'
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
                  key :'$ref', 'Workarea::Payment::SavedCreditCard'
                end
              end
            end
          end
        end

        def index
          @saved_credit_cards = @payment_profile.credit_cards.page(params[:page])
          respond_with saved_credit_cards: @saved_credit_cards
        end

        def create
          @saved_credit_card = @payment_profile.credit_cards.create!(
            params[:saved_credit_card]
          )

          respond_with(
            { saved_credit_card: @saved_credit_card },
            { status: :created,
            location: payment_profile_saved_credit_card_path(
              @payment_profile,
              @saved_credit_card
            ) }
          )
        end

        def show
          respond_with saved_credit_card: @saved_credit_card
        end

        swagger_path '/payment_profiles/{payment_profile_id}/saved_credit_cards/{id}' do
          operation :patch do
            key :summary, 'Update a Saved Credit Card'
            key :description, 'Updates attributes on a saved credit card'
            key :operationId, 'updateSavedCreditCard'

            parameter do
              key :name, :payment_profile_id
              key :in, :path
              key :description, 'ID of payment profile'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of saved credit card to update'
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
                property :saved_credit_card do
                  key :'$ref', 'Workarea::Payment::SavedCreditCard'
                end
              end
            end

            response 204 do
              key :description, 'Saved credit card updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Payment::SavedCreditCard'
                end
              end
            end

            response 404 do
              key :description, 'Payment profile or saved credit card not found'
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
            key :summary, 'Remove a Saved Credit Card'
            key :description, 'Remove a saved credit card'
            key :operationId, 'removeSavedCreditCard'

            parameter do
              key :name, :payment_profile_id
              key :in, :path
              key :description, 'ID of payment profile'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of saved credit card to update'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Saved credit card removed successfully'
            end

            response 404 do
              key :description, 'Payment profile or saved credit card not found'
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
          @saved_credit_card.update_attributes!(params[:saved_credit_card])
          respond_with saved_credit_card: @saved_credit_card
        end

        def bulk
          data = params[:saved_credit_cards].presence || []
          data.map!(&:to_h)
          data.map! { |attrs| attrs.merge(profile_id: @payment_profile.id) }

          @bulk = Api::Admin::BulkUpsert.create!(
            klass: Payment::SavedCreditCard,
            data: data
          )

          head :no_content
        end

        def destroy
          @saved_credit_card.destroy
          head :no_content
        end

        private

        def find_payment_profile
          @payment_profile = Payment::Profile.find(params[:payment_profile_id])
        end

        def find_saved_credit_card
          @saved_credit_card = @payment_profile.credit_cards.find(params[:id])
        end
      end
    end
  end
end
