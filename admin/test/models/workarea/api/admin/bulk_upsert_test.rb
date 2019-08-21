require 'test_helper'

module Workarea
  module Api
    module Admin
      class BulkUpsertTest < Workarea::TestCase
        def test_returns_false_without_data
          upsert = BulkUpsert.new(klass: Catalog::Product)
          refute(upsert.valid?)
          assert(upsert.errors[:data].present?)
        end

        def test_returns_false_with_invalid_data
          upsert = BulkUpsert.new(
            klass: Catalog::Product,
            data: [{ _id: '1234' }, { _id: '1234', name: 'Test Product' }]
          )

          refute(upsert.valid?)
          assert(upsert.errors['0'].present?)
        end

        def test_validates_max_data_size
          product = { _id: '34', name: 'Test Product' }

          upsert = BulkUpsert.new(
            klass: Catalog::Product,
            data: [product] * (Workarea.config.max_api_bulk_data_size + 1)
          )

          refute(upsert.valid?)
          assert_includes(upsert.errors[:data], I18n.t('workarea.api.admin.bulk_upserts.data_too_large'))
        end

        def test_upserts_based_on_id
          product = { name: 'Test Product' }
          upsert = BulkUpsert.new(klass: Catalog::Product, data: [product] * 3)

          assert_difference('Catalog::Product.count', 3) { upsert.perform! }

          product = create_product(name: 'Test')
          upsert = BulkUpsert.new(
            klass: Catalog::Product,
            data: [{ id: product.id, name: 'Foo' }]
          )

          upsert.perform!
          product.reload

          assert_equal('Foo', product.name)
        end

        def test_saves_errors
          upsert = BulkUpsert.new(
            klass: Catalog::Product,
            data: [{ name: '' }] * 3
          )

          upsert.perform!

          assert_equal(3, upsert.data_errors.length)
          assert(upsert.persisted?)
          refute(upsert.destroyed?)
        end

        def test_destroys_itself_on_success
          product = create_product(name: 'Test')
          upsert = BulkUpsert.new(
            klass: Catalog::Product,
            data: [{ id: product.id, name: 'Foo' }]
          )

          upsert.perform!
          assert(upsert.destroyed?)
        end
      end
    end
  end
end
