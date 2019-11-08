require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class SegmentationDocumentationTest < DocumentationTest
        resource 'Segmentation'

        def test_and_document_session_count
          description 'Specifying session count for segmentation'
          route storefront_api.system_content_path('home_page')
          explanation <<~EOS
            Workarea supports segmenting users by number of sessions, e.g.
            first-time vs returning visitors. To support this in the storefront
            API, the client will be responsible for managing this since the API
            is stateless (doesn't have cookies/session).

            To get session-based segments functioning, you need to pass a
            `sessions` parameter in each request. Workarea will use that as
            the number of sessions for determing the segments for the response.
            This works for all requests across the storefront API.

            This example shows getting a home page with segmented content based
            on the number of sessions.
          EOS

          first_time = Segment::FirstTimeVisitor.instance
          returning = Segment::ReturningVisitor.instance

          content = Content.for('Home Page')
          content.blocks.create!(
            type: 'text',
            data: { text: 'Hello visitor!' },
            active_segment_ids: [first_time.id]
          )
          content.blocks.create!(
            type: 'text',
            data: { text: 'Welcome back!' },
            active_segment_ids: [returning.id]
          )

          record_request do
            get storefront_api.system_content_path('home_page', sessions: 1)
            assert_match(/Hello visitor!/, response.body)
            assert(response.ok?)
          end
          record_request do
            get storefront_api.system_content_path('home_page', sessions: 2)
            assert_match(/Welcome back!/, response.body)
            assert(response.ok?)
          end
        end

        def test_and_document_session_ids
          description 'Using session IDs for segmenting non-authenticated users'
          route storefront_api.system_content_path('home_page')
          explanation <<~EOS
            Workarea supports segmenting users by number of orders, revenue, etc.
            For this functionality to work for users without accounts, you'll
            need to maintain and pass a `session_id` consistently throughout calls
            to the API.

            An instance of `Metrics::User` will be found or created for that
            `session_id`, and data about the user will be tracked there.

            Assuming use of the `session_id` consistently through checkout, this
            example shows getting home page content for two different anonymous
            users and getting segmented content back.
          EOS

          first_time = Segment::FirstTimeCustomer.instance
          returning = Segment::ReturningCustomer.instance

          Metrics::User.create!(id: 'session_1', orders: 1)
          Metrics::User.create!(id: 'session_2', orders: 2)

          content = Content.for('Home Page')
          content.blocks.create!(
            type: 'text',
            data: { text: 'Thanks for your order!' },
            active_segment_ids: [first_time.id]
          )
          content.blocks.create!(
            type: 'text',
            data: { text: 'Welcome back repeat customer!' },
            active_segment_ids: [returning.id]
          )

          record_request do
            get storefront_api.system_content_path('home_page', session_id: 'session_1')
            assert_match(/Thanks/, response.body)
            assert(response.ok?)
          end
          record_request do
            get storefront_api.system_content_path('home_page', session_id: 'session_2')
            assert_match(/Welcome back/, response.body)
            assert(response.ok?)
          end
        end
      end
    end
  end
end
