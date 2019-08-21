require 'test_helper'

module Workarea
  module Api
    module Storefront
      class SavedCreditCardsIntegrationTest < IntegrationTest
        include AuthenticationTest

        setup :set_user
        setup :set_payment_profile
        setup :set_credit_card

        def set_user
          @user = create_user(first_name: 'Ben', last_name: 'Crouse')
          set_current_user(@user)
        end

        def set_payment_profile
          @payment_profile = Payment::Profile.lookup(
            PaymentReference.new(@user)
          )
        end

        def set_credit_card
          @credit_card = @payment_profile.credit_cards.create!(
            number: '1',
            first_name: 'Ben',
            last_name: 'Crouse',
            month: '1',
            year: (Time.now.year + 1).to_s,
            cvv: '999'
          )
        end

        def test_index
          get storefront_api.saved_credit_cards_path
          result = JSON.parse(response.body)

          assert_equal(@user.id.to_s, result['user_id'])
          assert_equal(1, result['credit_cards'].count)
          assert_equal(@credit_card.id.to_s, result['credit_cards'].last['id'])
        end

        def test_show
          get storefront_api.saved_credit_card_path(@credit_card)
          result = JSON.parse(response.body)

          assert_equal(@user.id.to_s, result['user_id'])

          assert_equal(@credit_card.id.to_s, result['id'])
          assert_equal(@credit_card.first_name, result['first_name'])
          assert_equal(@credit_card.last_name, result['last_name'])
          assert_equal(@credit_card.display_number, result['display_number'])
          assert_equal(@credit_card.issuer, result['issuer'])
          assert_equal(@credit_card.month, result['month'])
          assert_equal(@credit_card.year, result['year'])
          assert_equal(@credit_card.default, result['default'])
        end

        def test_create
          post storefront_api.saved_credit_cards_path,
            params: {
              number: '4111111111111111',
              first_name: 'Ben',
              last_name: 'Crouse',
              month: '5',
              year: (Time.now.year + 1).to_s,
              cvv: '123'
            }

          assert(response.ok?)
          assert(2, @payment_profile.reload.credit_cards.count)

          credit_card = @payment_profile.reload.credit_cards.last
          assert_equal(5, credit_card.month)
          assert_equal(
            ActiveMerchant::Billing::CreditCard.mask('4111111111111111'),
            credit_card.display_number
          )
        end

        def test_update
          year = Time.now.year + 2

          patch storefront_api.saved_credit_card_path(@credit_card),
            params: {
              month: '5',
              year: year.to_s,
              cvv: '123'
            }

          assert(response.ok?)
          assert(1, @payment_profile.reload.credit_cards.count)

          credit_card = @payment_profile.reload.credit_cards.first
          assert_equal(5, credit_card.month)
          assert_equal(year, credit_card.year)
        end

        def test_destroy
          delete storefront_api.saved_credit_card_path(@credit_card)
          assert_equal(0, @payment_profile.reload.credit_cards.count)
        end
      end
    end
  end
end
