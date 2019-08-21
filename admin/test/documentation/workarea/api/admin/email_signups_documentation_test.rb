require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class EmailSignupsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Email Signups'

        def test_and_document_index
          description 'Listing email signups'
          route admin_api.email_signups_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { |i| create_email_signup(email: "#{i}@workarea.com") }

          record_request do
            get admin_api.email_signups_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_show
          description 'Showing an email signup'
          route admin_api.email_signup_path(':id')

          record_request do
            get admin_api.email_signup_path(create_email_signup.id)
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
