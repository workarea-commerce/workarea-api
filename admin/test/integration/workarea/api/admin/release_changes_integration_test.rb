require 'test_helper'

module Workarea
  module Api
    module Admin
      class ReleaseChangesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @release = create_release(name: 'API Release')
          @sample_attributes = create_product
                                .as_json
                                .except('_id', 'slug', 'last_indexed_at')
        end

        def test_creates_a_changeset_for_the_specific_release
          product = create_product(name: 'foo')
          patch admin_api.product_path(product.id),
            params: { product: { name: 'bar' }, release_id: @release.id.to_s }

          product.reload
          assert_equal('foo', product.name)

          changes = product.changesets.first
          assert_equal({ I18n.locale.to_s => 'bar' }, changes.changeset[:name])
        end
      end
    end
  end
end
