require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class SavedCreditCardsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Saved Credit Cards'

        def payment_profile
          @payment_profile ||= create_payment_profile
        end

        def sample_attributes
          @sample_attributes ||= create_saved_credit_card(profile_id: payment_profile.id)
            .as_json
            .except('_id')
        end

        def test_and_document_index
          description 'Listing saved credit cards'
          route admin_api.payment_profile_saved_credit_cards_path(':payment_profile_id')
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_saved_credit_card(profile: payment_profile) }

          record_request do
            get admin_api.payment_profile_saved_credit_cards_path(payment_profile.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a saved credit card'
          route admin_api.payment_profile_saved_credit_cards_path(':payment_profile_id')

          record_request do
            post admin_api.payment_profile_saved_credit_cards_path(payment_profile.id),
                  params: { saved_credit_card: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a saved credit card'
          route admin_api.payment_profile_saved_credit_card_path(':payment_profile_id', ':id')

          saved_credit_card = create_saved_credit_card(profile: payment_profile)

          record_request do
            patch admin_api.payment_profile_saved_credit_card_path(
              payment_profile.id,
                    saved_credit_card.id
            ),
                  params: { saved_credit_card: { first_name: 'Ben' } },
                  as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a saved credit card'
          route admin_api.payment_profile_saved_credit_card_path(':payment_profile_id', ':id')

          saved_credit_card = create_saved_credit_card(profile: payment_profile)

          record_request do
            delete admin_api.payment_profile_saved_credit_card_path(
              payment_profile.id,
              saved_credit_card.id
            )

            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
