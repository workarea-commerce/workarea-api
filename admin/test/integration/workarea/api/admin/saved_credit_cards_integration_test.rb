require 'test_helper'

module Workarea
  module Api
    module Admin
      class SavedCreditCardsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @profile = create_payment_profile
          @sample_attributes = create_saved_credit_card(profile_id: @profile.id)
                                .as_json
                                .except('_id')
        end

        def test_lists_credit_cards
          credit_cards = [
            create_saved_credit_card(profile: @profile),
            create_saved_credit_card(profile: @profile)
          ]

          get admin_api.payment_profile_saved_credit_cards_path(@profile)
          result = JSON.parse(response.body)['saved_credit_cards']

          assert_equal(2, result.length)
          assert_equal(
            credit_cards.first,
            Payment::SavedCreditCard.new(result.first)
          )
          assert_equal(
            credit_cards.second,
            Payment::SavedCreditCard.new(result.second)
          )
        end

        def test_creates_credit_cards
          assert_difference 'Payment::SavedCreditCard.count', 1 do
            post admin_api.payment_profile_saved_credit_cards_path(@profile),
              params: { saved_credit_card: @sample_attributes }
          end
        end

        def test_shows_credit_cards
          credit_card = create_saved_credit_card(profile: @profile)
          get admin_api.payment_profile_saved_credit_card_path(@profile, credit_card)
          result = JSON.parse(response.body)['saved_credit_card']
          assert_equal(credit_card, Payment::SavedCreditCard.new(result))
        end

        def test_updates_credit_cards
          credit_card = create_saved_credit_card(profile: @profile)
          patch admin_api.payment_profile_saved_credit_card_path(@profile, credit_card),
            params: { saved_credit_card: { first_name: 'Ben' } }

          assert_equal('Ben', credit_card.reload.first_name)
        end

        def test_bulk_upserts_credit_cards
          assert_difference 'Payment::SavedCreditCard.count', 10 do
            patch admin_api.bulk_payment_profile_saved_credit_cards_path(@profile),
              params: { saved_credit_cards: [@sample_attributes] * 10 }
          end
        end

        def test_destroys_credit_cards
          credit_card = create_saved_credit_card(profile: @profile)
          assert_difference 'Payment::SavedCreditCard.count', -1 do
            delete admin_api.payment_profile_saved_credit_card_path(@profile, credit_card)
          end
        end
      end
    end
  end
end
