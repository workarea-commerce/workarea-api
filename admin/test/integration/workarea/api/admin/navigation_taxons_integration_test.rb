require 'test_helper'

module Workarea
  module Api
    module Admin
      class NavigationTaxonsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_taxon.as_json.except('_id')
        end

        def test_lists_taxons
          2.times { create_taxon }
          get admin_api.navigation_taxons_path
          result = JSON.parse(response.body)['navigation_taxons']
          assert_equal(4, result.length)
        end

        def test_creates_taxons
          assert_difference 'Navigation::Taxon.count', 1 do
            post admin_api.navigation_taxons_path,
              params: { navigation_taxon: @sample_attributes }
          end
        end

        def test_shows_taxons
          taxon = create_taxon
          get admin_api.navigation_taxon_path(taxon.id)
          result = JSON.parse(response.body)['navigation_taxon']
          assert_equal(taxon, Navigation::Taxon.new(result))
        end

        def test_updates_taxons
          taxon = create_taxon
          patch admin_api.navigation_taxon_path(taxon.id),
            params: { navigation_taxon: { name: 'foo' } }

          assert_equal('foo', taxon.reload.name)
        end

        def test_bulk_upserts_taxons
          data = [@sample_attributes] * 10

          assert_difference 'Navigation::Taxon.count', 10 do
            patch admin_api.bulk_navigation_taxons_path,
              params: { navigation_taxons: data }
          end
        end

        def test_destroys_taxons
          taxon = create_taxon

          assert_difference 'Navigation::Taxon.count', -1 do
            delete admin_api.navigation_taxon_path(taxon.id)
          end
        end
      end
    end
  end
end
