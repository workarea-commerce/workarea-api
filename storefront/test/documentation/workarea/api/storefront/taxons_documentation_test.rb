require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class TaxonsDocumentationTest < DocumentationTest
        resource 'Taxons'

        setup :set_taxons

        def set_taxons
          @taxon = create_taxon(
            name: 'Mens',
            url: 'http://example.com/pages/mens'
          )

          @taxon.children.create!(name: 'Sale')
        end

        def test_and_document_show
          description 'Showing a taxon'
          route storefront_api.taxon_path(':id')
          explanation <<-EOS
            This endpoint will show details on a particular node (or taxon) of
            the site taxonomy, along with its children.
          EOS

          record_request do
            get storefront_api.taxon_path(@taxon)
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
