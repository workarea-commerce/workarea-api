require 'test_helper'

module Workarea
  module Api
    module Admin
      class PaymentProfilesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_payment_profile.as_json.except('_id')
        end

        def test_lists_payment_profiles
          profiles = [
            create_payment_profile(reference: '1'),
            create_payment_profile(reference: '2')
          ]
          get admin_api.payment_profiles_path
          result = JSON.parse(response.body)['payment_profiles']

          assert_equal(3, result.length)
          assert_equal(profiles.second, Payment::Profile.new(result.first))
          assert_equal(profiles.first, Payment::Profile.new(result.second))

          travel_to 1.week.from_now

          get admin_api.payment_profiles_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['payment_profiles']

          assert_equal(0, result.length)

          get admin_api.payment_profiles_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['payment_profiles']

          assert_equal(0, result.length)

          get admin_api.payment_profiles_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['payment_profiles']
          assert_equal(3, result.length)

          get admin_api.payment_profiles_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['payment_profiles']
          assert_equal(3, result.length)
        end

        def test_creates_payment_profiles
          data = @sample_attributes.merge('reference' => '2')

          assert_difference 'Payment::Profile.count', 1 do
            post admin_api.payment_profiles_path, params: { payment_profile: data }
          end
        end

        def test_shows_payment_profiles
          profile = create_payment_profile(reference: 'foo')
          get admin_api.payment_profile_path(profile.id)
          result = JSON.parse(response.body)['payment_profile']
          assert_equal(profile, Payment::Profile.new(result))
        end

        def test_updates_payment_profiles
          profile = create_payment_profile(reference: 'foo')
          patch admin_api.payment_profile_path(profile.id),
            params: { payment_profile: { store_credit: 29 } }

          profile.reload
          assert_equal(29.to_m, profile.store_credit)
        end

        def test_bulk_upserts_payment_profiles
          count = 0
          data = Array.new(10) do
            count += 1
            @sample_attributes.merge('reference' => count)
          end

          assert_difference 'Payment::Profile.count', 10 do
            patch admin_api.bulk_payment_profiles_path,
              params: { payment_profiles: data }
          end
        end

        def test_destroys_payment_profiles
          profile = create_payment_profile(reference: 'foo')

          assert_difference 'Payment::Profile.count', -1 do
            delete admin_api.payment_profile_path(profile.id)
          end
        end
      end
    end
  end
end
