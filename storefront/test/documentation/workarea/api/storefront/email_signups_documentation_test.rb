require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class EmailSignupsDocumentationTest < DocumentationTest
        resource 'Email Signups'

        setup :set_content

        def set_content
          page = Workarea::Storefront::EmailSignupsViewModel.new
          page.content.blocks.create!(
            type: :text,
            data: { text: 'Here is some administrated content' }
          )
        end

        def test_and_document_show
          description 'Showing an email signup content'
          route storefront_api.email_signups_path
          explanation <<-EOS
            This endpoint will return all relevant data for showing an email
            sign up form.
          EOS

          record_request do
            get storefront_api.email_signups_path
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating an email signup'
          route storefront_api.email_signups_path
          explanation <<-EOS
            Use this endpoint to create an email signup. This will usually be
            forwarded to an Email Service Provider, but Workarea will keep a
            record of it just in case.
          EOS

          record_request do
            post storefront_api.email_signups_path,
              as: :json,
              params: { email: 'email@example.com' }
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
