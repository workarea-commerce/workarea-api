require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class ContactsDocumentationTest < DocumentationTest
        resource 'Contacts'

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

        def test_and_document_create
          description 'Creating a contact'
          route storefront_api.contacts_path
          explanation <<-EOS
            This endpoints creates a customer service inquiry on behalf of the
            customer, and will send an email to the address in
            Workarea.config.email_to
          EOS

          record_request do
            post storefront_api.contacts_path, params: @contact_params, as: :json
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
