module Workarea
  module Api
    module Storefront
      class SavedCreditCardsController < Api::Storefront::ApplicationController
        before_action :set_payment_profile

        def index
          @credit_cards = @payment_profile.credit_cards
        end

        def show
          @credit_card = @payment_profile.credit_cards.find(params[:id])
        end

        def create
          @credit_card = @payment_profile.credit_cards.create!(card_params)
          render :show
        end

        def update
          @credit_card = @payment_profile.credit_cards.find(params[:id])

          @credit_card.update_attributes!(card_params)
          render :show
        end

        def destroy
          @payment_profile.credit_cards.find(params[:id]).destroy
          head :no_content
        end

        private

        def set_payment_profile
          @payment_profile ||= Payment::Profile.lookup(
            PaymentReference.new(current_user)
          )
        end

        def card_params
          params.permit(
            :first_name,
            :last_name,
            :number,
            :month,
            :year,
            :cvv,
            :default
          )
        end
      end
    end
  end
end
