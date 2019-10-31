require 'test_helper'

module Workarea
  module Api
    module Storefront
      class TaxonsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        setup :set_taxons

        def set_taxons
          @taxon = create_taxon(
            name: 'Mens',
            url: 'http://example.com/pages/mens'
          )

          @taxon.children.create!(name: 'Sale')
        end

        def test_show
          get storefront_api.taxon_path(@taxon)
          result = JSON.parse(response.body)

          assert_equal(@taxon.id.to_s, result['taxon']['id'])
          assert_equal(
            'http://example.com/pages/mens',
            result['taxon']['navigable_url']
          )

          assert_equal(1, result['children'].size)
        end

        def test_inactive_taxon
          @taxon.update_attributes!(
            url: nil,
            navigable: create_page(active: false)
          )

          get storefront_api.taxon_path(@taxon)
          refute(response.ok?)
          assert_equal(404, response.status)
        end
      end
    end
  end
end
