require 'test_helper'

module Workarea
  module Api
    module Storefront
      class EmailSignupsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        setup :set_content

        def set_content
          page = Workarea::Storefront::EmailSignupsViewModel.new
          page.content.blocks.create!(
            type: :text,
            data: { text: 'foo bar' }
          )
        end

        def test_show_email_signups
          get storefront_api.email_signups_path
          result = JSON.parse(response.body)

          result_block = result['content_blocks'].first
          assert_equal('text', result_block['type'])
          assert_equal('foo bar', result_block['data']['text'])
        end

        def test_create_email_signups
          assert_difference 'Email::Signup.count', 2 do
            post storefront_api.email_signups_path, params: { email: 'email@example.com' }
            post storefront_api.email_signups_path, params: { email: 'email2@example.com' }
          end
        end
      end
    end
  end
end
