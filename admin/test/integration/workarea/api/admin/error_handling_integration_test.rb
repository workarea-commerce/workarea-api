require 'test_helper'

module Workarea
  module Api
    module Admin
      class ErrorHandlingIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include Workarea::Admin::IntegrationTest

        def test_handles_mongoid_not_found
          patch admin_api.product_path('FOO'), params: { product: { name: 'foo' } }
          assert_equal(404, response.status)
        end
      end
    end
  end
end
