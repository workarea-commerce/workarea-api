require 'test_helper'

module Workarea
  module Api
    module Storefront
      class SegmentsIntegrationTest < IntegrationTest
        include AuthenticationTest

        def test_sessions_functionality
          first_time = Segment::FirstTimeVisitor.instance
          returning = Segment::ReturningVisitor.instance

          get storefront_api.system_content_path('home_page')
          assert_equal(first_time.id.to_s, response.headers['X-Workarea-Segments'])

          get storefront_api.system_content_path('home_page'), params: { sessions: 1 }
          assert_equal(first_time.id.to_s, response.headers['X-Workarea-Segments'])

          get storefront_api.system_content_path('home_page'), params: { sessions: 2 }
          assert_equal(returning.id.to_s, response.headers['X-Workarea-Segments'])
        end

        def test_current_email_functionality
          first_time = Segment::FirstTimeCustomer.instance
          returning = Segment::ReturningCustomer.instance

          Metrics::User.save_order(email: 'first-time@workarea.com', revenue: 1.to_m)
          Metrics::User.save_order(email: 'returning@workarea.com', revenue: 1.to_m)
          Metrics::User.save_order(email: 'returning@workarea.com', revenue: 1.to_m)

          get storefront_api.system_content_path('home_page')
          assert(response.headers['X-Workarea-Segments'].blank?)

          get storefront_api.system_content_path('home_page'), params: { email: 'first-time@workarea.com' }
          assert_equal(first_time.id.to_s, response.headers['X-Workarea-Segments'])

          get storefront_api.system_content_path('home_page'), params: { email: 'returning@workarea.com' }
          assert_equal(returning.id.to_s, response.headers['X-Workarea-Segments'])
        end

        def test_session_ids_for_metrics
          first_time = Segment::FirstTimeCustomer.instance
          returning = Segment::ReturningCustomer.instance

          Metrics::User.create!(id: '1', orders: 1)
          Metrics::User.create!(id: '2', orders: 2)

          get storefront_api.system_content_path('home_page')
          assert(response.headers['X-Workarea-Segments'].blank?)

          get storefront_api.system_content_path('home_page'), params: { session_id: '1' }
          assert_equal(first_time.id.to_s, response.headers['X-Workarea-Segments'])

          get storefront_api.system_content_path('home_page'), params: { session_id: '2' }
          assert_equal(returning.id.to_s, response.headers['X-Workarea-Segments'])
        end

        def test_products_active_by_segment
          segment_one = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 1, maximum: 1)])
          segment_two = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 2, maximum: 2)])
          product_one = create_product(active: true, active_segment_ids: [segment_two.id])
          product_two = create_product(active: true, active_segment_ids: [segment_one.id])

          assert_raise InvalidDisplay do
            get storefront_api.product_path(product_one), params: { sessions: 0 }
            assert(response.not_found?)
          end

          assert_raise InvalidDisplay do
            get storefront_api.product_path(product_two), params: { sessions: 0 }
            assert(response.not_found?)
          end

          get storefront_api.search_path(q: '*'), params: { sessions: 0 }
          assert(JSON.parse(response.body)['products'].empty?)

          assert_raise InvalidDisplay do
            get storefront_api.product_path(product_one), params: { sessions: 1 }
            assert(response.not_found?)
          end

          get storefront_api.product_path(product_two), params: { sessions: 1 }
          assert(response.ok?)

          get storefront_api.search_path(q: '*'), params: { sessions: 1 }
          products = JSON.parse(response.body)['products']
          assert_equal([product_two.id], products.map { |p| p['id'] })

          get storefront_api.product_path(product_one), params: { sessions: 2 }
          assert(response.ok?)

          assert_raise InvalidDisplay do
            get storefront_api.product_path(product_two), params: { sessions: 2 }
            assert(response.not_found?)
          end

          get storefront_api.search_path(q: '*'), params: { sessions: 2 }
          products = JSON.parse(response.body)['products']
          assert_equal([product_one.id], products.map { |p| p['id'] })

          segment_one.rules.first.update!(minimum: 1, maximum: nil)
          segment_two.rules.first.update!(minimum: 1, maximum: nil)

          get storefront_api.product_path(product_one), params: { sessions: 1 }
          assert(response.ok?)

          get storefront_api.product_path(product_two), params: { sessions: 1 }
          assert(response.ok?)

          get storefront_api.search_path(q: '*'), params: { sessions: 1 }
          products = JSON.parse(response.body)['products']
          assert_equal(2, products.count)
          assert_includes(products.map { |r| r['id'] }, product_one.id)
          assert_includes(products.map { |r| r['id'] }, product_two.id)
        end

        def test_content_active_by_segment
          segment_one = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 1, maximum: 1)])
          segment_two = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 2, maximum: 2)])

          content = Content.for('home_page')
          foo = content.blocks.create!(
            type: 'html',
            data: { 'html' => '<p>Foo</p>' },
            active_segment_ids: [segment_one.id]
          )
          bar = content.blocks.create!(
            type: 'html',
            data: { 'html' => '<p>Bar</p>' },
            active_segment_ids: [segment_two.id]
          )

          get storefront_api.system_content_path('home_page'), params: { sessions: 1 }
          content_blocks = JSON.parse(response.body)['content_blocks']
          assert_equal([foo.id.to_s], content_blocks.map { |cb| cb['id'] })

          get storefront_api.system_content_path('home_page'), params: { sessions: 2 }
          content_blocks = JSON.parse(response.body)['content_blocks']
          assert_equal([bar.id.to_s], content_blocks.map { |cb| cb['id'] })

          segment_one.rules.first.update!(minimum: 1, maximum: nil)
          segment_two.rules.first.update!(minimum: 1, maximum: nil)

          get storefront_api.system_content_path('home_page'), params: { sessions: 1 }
          content_blocks = JSON.parse(response.body)['content_blocks']
          assert_equal([foo.id.to_s, bar.id.to_s], content_blocks.map { |cb| cb['id'] })
        end

        def test_logged_in_based_segments
          logged_in = create_segment(rules: [Segment::Rules::LoggedIn.new(logged_in: true)])
          logged_out = create_segment(rules: [Segment::Rules::LoggedIn.new(logged_in: false)])

          get storefront_api.system_content_path('home_page')
          assert_equal(logged_out.id.to_s, response.headers['X-Workarea-Segments'])

          user = create_user
          post storefront_api.authentication_tokens_path,
            params: { email: user.email, password: user.password }

          token = JSON.parse(response.body)['token']
          get storefront_api.system_content_path('home_page'),
            headers: { 'HTTP_AUTHORIZATION' => encode_credentials(token) }
          assert_equal(logged_in.id.to_s, response.headers['X-Workarea-Segments'])
        end

        def test_http_caching_headers_for_segmented_content
          Workarea.config.strip_http_caching_in_tests = false
          segment = create_segment(rules: [Segment::Rules::Sessions.new(maximum: 999)])

          get storefront_api.system_content_path('home_page')
          refute_match(/private/, response.headers['Cache-Control'])
          assert_match(/public/, response.headers['Cache-Control'])
          assert(response.headers['X-Workarea-Segmented-Content'].blank?)

          content = Content.for('home_page')
          content.blocks.create!(
            type: 'html',
            data: { 'html' => '<p>Foo</p>' },
            active_segment_ids: [segment.id]
          )

          get storefront_api.system_content_path('home_page')
          assert_match(/private/, response.headers['Cache-Control'])
          refute_match(/public/, response.headers['Cache-Control'])
          assert_equal('true', response.headers['X-Workarea-Segmented-Content'])

          product = create_product(active: true, active_segment_ids: [])
          get storefront_api.product_path(product)
          assert(response.ok?)
          refute_match(/private/, response.headers['Cache-Control'])
          assert_match(/public/, response.headers['Cache-Control'])
          assert(response.headers['X-Workarea-Segmented-Content'].blank?)

          product.update!(active_segment_ids: [segment.id])
          get storefront_api.product_path(product)
          assert(response.ok?)
          assert_match(/private/, response.headers['Cache-Control'])
          refute_match(/public/, response.headers['Cache-Control'])
          assert_equal('true', response.headers['X-Workarea-Segmented-Content'])

          category = create_category(active: true, active_segment_ids: [])
          get storefront_api.category_path(category)
          assert(response.ok?)
          refute_match(/private/, response.headers['Cache-Control'])
          assert_match(/public/, response.headers['Cache-Control'])
          assert(response.headers['X-Workarea-Segmented-Content'].blank?)

          category.update!(product_ids: [product.id])
          get storefront_api.category_path(category)
          assert(response.ok?)
          assert_match(/private/, response.headers['Cache-Control'])
          refute_match(/public/, response.headers['Cache-Control'])
          assert_equal('true', response.headers['X-Workarea-Segmented-Content'])
        end
      end
    end
  end
end
