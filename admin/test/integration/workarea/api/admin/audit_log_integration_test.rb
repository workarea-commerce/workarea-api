require 'test_helper'

module Workarea
  module Api
    module Admin
      class AuditLogIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        include Workarea::Admin::IntegrationTest

        def test_records_changes_in_the_audit_log
          assert_difference 'Mongoid::AuditLog::Entry.count', 1 do
            product = create_product

            patch admin_api.product_path(product.id),
              params: { product: { name: 'foo' } }
          end
        end
      end
    end
  end
end
