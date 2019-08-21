require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class SavedCreditCardsDocumentationTest < DocumentationTest
        include AuthenticationTest

        resource 'Saved Credit Cards'

        setup :set_user
        setup :set_payment_profile
        setup :set_credit_card

        def set_user
          @user = create_user(first_name: 'Susan', last_name: 'Baker')
          @auth = @user.authentication_tokens.create!
        end

        def set_payment_profile
          @payment_profile = Payment::Profile.lookup(
            PaymentReference.new(@user)
          )
        end

        def set_credit_card
          @credit_card = @payment_profile.credit_cards.create!(
            number: '4012888888881881',
            first_name: 'Susan',
            last_name: 'Baker',
            month: '3',
            year: (Time.now.year + 4).to_s,
            cvv: '999'
          )
        end

        def test_and_show_index_of_credit_cards
          @payment_profile.credit_cards.create!(
            number: '4111111111111111',
            first_name: 'Susan',
            last_name: 'Baker',
            month: '7',
            year: (Time.now.year + 5).to_s,
            cvv: '999'
          )

          description 'Listing the user\'s saved credit cards'
          route storefront_api.saved_credit_cards_path
          explanation <<-EOS
            List a customer's saved addresses. Useful for account management.
            These addresses will be available to the customer in an
            authenticated checkout.
          EOS

          record_request do
            get storefront_api.saved_credit_cards_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_show_a_single_credit_card
          description 'Showing a saved credit card'
          route storefront_api.saved_credit_card_path(':id')

          record_request do
            get storefront_api.saved_credit_card_path(@credit_card),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_creating_a_new_credit_card
          description 'Creating a saved credit card'
          route storefront_api.saved_credit_cards_path

          record_request do
            post storefront_api.saved_credit_cards_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) },
              as: :json,
              params: {
                number: '4111111111111111',
                first_name: 'Susan',
                last_name: 'Baker',
                month: '7',
                year: (Time.now.year + 5).to_s,
                cvv: '123'
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_updating_an_credit_card
          description 'Updating a saved credit card'
          route storefront_api.saved_credit_card_path(':id')

          record_request do
            patch storefront_api.saved_credit_card_path(@credit_card),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) },
              as: :json,
              params: {
                month: '7',
                year: (Time.now.year + 5).to_s,
                cvv: '123'
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_deleting_an_credit_card
          description 'Deleting a saved credit card'
          route storefront_api.saved_credit_card_path(':id')

          record_request do
            delete storefront_api.saved_credit_card_path(@credit_card),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
