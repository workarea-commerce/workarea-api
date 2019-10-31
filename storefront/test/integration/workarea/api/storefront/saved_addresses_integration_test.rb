require 'test_helper'

module Workarea
  module Api
    module Storefront
      class SavedAddressesIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        include AuthenticationTest

        setup :set_user
        setup :set_address

        def set_user
          @user = create_user(first_name: 'Ben', last_name: 'Crouse')
          set_current_user(@user)
        end

        def set_address
          @address = @user.addresses.create!(
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '12 N. 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            country: 'US',
            postal_code: '19106',
            phone_number: '2159251800'
          )
        end

        def test_index
          get storefront_api.saved_addresses_path
          result = JSON.parse(response.body)

          assert_equal(@user.id.to_s, result['user_id'])
          assert_equal(1, result['addresses'].count)
          assert_equal(@address.id.to_s, result['addresses'].last['id'])
        end

        def test_show
          get storefront_api.saved_address_path(@address)
          result = JSON.parse(response.body)

          assert_equal(@user.id.to_s, result['user_id'])

          assert_equal(@address.id.to_s, result['id'])
          assert_equal(@address.first_name, result['first_name'])
          assert_equal(@address.last_name, result['last_name'])
          assert_equal(@address.street, result['street'])
          assert_equal(@address.city, result['city'])
          assert_equal(@address.country.alpha2, result['country'])
          assert_equal(@address.region, result['region'])
          assert_equal(@address.postal_code, result['postal_code'])
          assert_equal(@address.phone_number, result['phone_number'])
        end

        def test_create
          post storefront_api.saved_addresses_path,
            params: {
              first_name: 'Ben',
              last_name: 'Crouse',
              street: '22 S. 3rd St.',
              street_2: 'Second Floor',
              city: 'Philadelphia',
              region: 'PA',
              country: 'US',
              postal_code: '19106',
              phone_number: '2159251800'
            }

          assert(response.ok?)
          assert(2, @user.reload.addresses.count)

          address = @user.reload.addresses.last
          assert_equal('22 S. 3rd St.', address.street)
          assert_equal('Second Floor', address.street_2)
        end

        def test_update
          patch storefront_api.saved_address_path(@address),
            params: {
              street: '22 S. 3rd St.',
              street_2: 'Second Floor'
            }

          assert(response.ok?)
          assert(1, @user.reload.addresses.count)

          address = @user.reload.addresses.first
          assert_equal('22 S. 3rd St.', address.street)
          assert_equal('Second Floor', address.street_2)
        end

        def test_destroy
          delete storefront_api.saved_address_path(@address)
          assert_equal(0, @user.reload.addresses.count)
        end
      end
    end
  end
end
