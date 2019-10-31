require 'test_helper'

module Workarea
  module Api
    module Admin
      class RedirectsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_redirect.as_json.except('_id')
        end

        def test_lists_redirects
          redirects = [create_redirect(path: '/1'), create_redirect(path: '/2')]
          get admin_api.redirects_path
          result = JSON.parse(response.body)['redirects']

          assert_equal(3, result.length)
          assert_equal(redirects.second, Navigation::Redirect.new(result.first))
          assert_equal(redirects.first, Navigation::Redirect.new(result.second))

          travel_to 1.week.from_now

          get admin_api.redirects_path(
            updated_at_starts_at: 2.days.ago,
            updated_at_ends_at: 1.day.ago
          )
          result = JSON.parse(response.body)['redirects']
          assert_equal(0, result.length)

          get admin_api.redirects_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['redirects']
          assert_equal(0, result.length)

          get admin_api.redirects_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.day.from_now
          )

          result = JSON.parse(response.body)['redirects']
          assert_equal(3, result.length)

          get admin_api.redirects_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['redirects']
          assert_equal(3, result.length)
        end

        def test_creates_redirects
          assert_difference 'Navigation::Redirect.count', 1 do
            post admin_api.redirects_path,
              params: { redirect: @sample_attributes.merge('path' => '/2') }
          end
        end

        def test_shows_redirects
          redirect = create_redirect(path: '/foo')
          get admin_api.redirect_path(redirect.id)
          result = JSON.parse(response.body)['redirect']
          assert_equal(redirect, Navigation::Redirect.new(result))
        end

        def test_updates_redirects
          redirect = create_redirect(path: '/foo')
          patch admin_api.redirect_path(redirect.id),
            params: { redirect: { path: '/foo' } }

          assert_equal('/foo', redirect.reload.path)
        end

        def test_bulk_upserts_redirects
          count = 0
          data = Array.new(10) do
            count += 1
            @sample_attributes.merge('path' => "/#{count}")
          end

          assert_difference 'Navigation::Redirect.count', 10 do
            patch admin_api.bulk_redirects_path, params: { redirects: data }
          end
        end

        def test_destroys_redirects
          redirect = create_redirect(path: '/foo')

          assert_difference 'Navigation::Redirect.count', -1 do
            delete admin_api.redirect_path(redirect.id)
          end
        end
      end
    end
  end
end
