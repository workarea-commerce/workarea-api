require 'test_helper'

module Workarea
  module Api
    module Storefront
      class ApplicationHelperTest < ViewTest
        include Engine.routes.url_helpers

        def test_storefront_api_url_for
          navigable = create_page
          taxon = create_taxon(navigable: navigable)

          refute_includes(storefront_api_url_for(taxon), ':3000')
        end

        private

        def default_url_options(*)
          { host: 'example.com' }
        end
      end
    end
  end
end
