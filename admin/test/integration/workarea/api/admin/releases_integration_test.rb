require 'test_helper'

module Workarea
  module Api
    module Admin
      class ReleasesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_release.as_json.except('_id')
        end

        def test_lists_releases
          releases = [create_release, create_release]
          get admin_api.releases_path
          result = JSON.parse(response.body)['releases']

          assert_equal(3, result.length)
          assert_equal(releases.second, Release.new(result.first))
          assert_equal(releases.first, Release.new(result.second))
        end

        def test_creates_releases
          assert_difference 'Release.count', 1 do
            post admin_api.releases_path, params: { release: @sample_attributes }
          end
        end

        def test_shows_releases
          release = create_release
          get admin_api.release_path(release.id)
          result = JSON.parse(response.body)['release']
          assert_equal(release, Release.new(result))
        end

        def test_updates_releases
          release = create_release
          patch admin_api.release_path(release.id), params: { release: { name: 'foo' } }
          assert_equal('foo', release.reload.name)
        end

        def test_bulk_upserts_releases
          assert_difference 'Release.count', 10 do
            patch admin_api.bulk_releases_path,
              params: { releases: [@sample_attributes] * 10 }
          end
        end

        def test_destroys_releases
          release = create_release
          assert_difference 'Release.count', -1 do
            delete admin_api.release_path(release.id)
          end
        end
      end
    end
  end
end
