require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class ReleaseChangesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Release Changes'

        def test_and_document_create
          description 'Adding changes to a release'
          route admin_api.product_path(':id')
          explanation "release_id can be sent with any patch request \
            to resources that can be changed through releases"

          record_request do
            patch admin_api.product_path(create_product.id),
                    params: {
                      product: { name: 'foo' },
                      release_id: create_release.id
                    },
                    as: :json

            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
