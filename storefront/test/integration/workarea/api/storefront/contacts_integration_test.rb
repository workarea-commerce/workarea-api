require 'test_helper'

module Workarea
  module Api
    module Storefront
      class ContactsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        setup :set_contact_params

        def set_contact_params
          @contact_params = {
            name: 'Name',
            email: 'email@example.com',
            order_id: 'OrderID',
            subject: :orders,
            message: 'Message'
          }
        end

        def test_create_inquiries
          data = @contact_params
          assert_difference 'Inquiry.count', 1 do
            post storefront_api.contacts_path, params: data
          end
        end
      end
    end
  end
end
