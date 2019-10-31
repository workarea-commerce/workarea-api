require 'test_helper'

module Workarea
  module Api
    module Admin
      class SavedAddressesIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @user = create_user

          @sample_attributes = {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          }
        end

        def create_address
          @count ||= 0
          @count += 1

          @user.addresses.create!(
            @sample_attributes.merge(street: "#{@count} S 3rd St")
          )
        end

        def test_lists_addresses
          addresses = [create_address, create_address]
          get admin_api.user_saved_addresses_path(@user.id)
          result = JSON.parse(response.body)['saved_addresses']

          assert_equal(2, result.length)
          assert_equal(addresses.first, User::SavedAddress.new(result.first))
          assert_equal(addresses.second, User::SavedAddress.new(result.second))
        end

        def test_creates_addresses
          assert_difference '@user.reload.addresses.count', 1 do
            post admin_api.user_saved_addresses_path(@user.id),
              params: { saved_address: @sample_attributes }
          end
        end

        def test_updates_addresses
          address = create_address
          patch admin_api.user_saved_address_path(@user.id, address.id),
            params: { saved_address: { first_name: 'foo' } }

          assert_equal('foo', address.reload.first_name)
        end

        def test_destroys_addresses
          address = create_address

          assert_difference '@user.reload.addresses.count', -1 do
            delete admin_api.user_saved_address_path(@user.id, address.id)
          end
        end
      end
    end
  end
end
