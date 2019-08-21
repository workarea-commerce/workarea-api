require 'test_helper'

module Workarea
  module Api
    module Admin
      class PromoCodeListsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_code_list.as_json.except('_id')
        end

        def test_lists_promo_code_lists
          promo_code_lists = [create_code_list, create_code_list]
          get admin_api.promo_code_lists_path
          result = JSON.parse(response.body)['promo_code_lists']

          assert_equal(3, result.length)
          assert_equal(
            promo_code_lists.second,
            Pricing::Discount::CodeList.new(result.first)
          )
          assert_equal(
            promo_code_lists.first,
            Pricing::Discount::CodeList.new(result.second)
          )
        end

        def test_creates_promo_code_lists
          assert_difference 'Pricing::Discount::CodeList.count', 1 do
            post admin_api.promo_code_lists_path,
              params: { promo_code_list: @sample_attributes }
          end
        end

        def test_shows_promo_code_lists
          promo_code_list = create_code_list
          get admin_api.promo_code_list_path(promo_code_list.id)
          result = JSON.parse(response.body)['promo_code_list']
          assert_equal(promo_code_list, Pricing::Discount::CodeList.new(result))
        end

        def test_updates_promo_code_lists
          promo_code_list = create_code_list
          patch admin_api.promo_code_list_path(promo_code_list.id),
            params: { promo_code_list: { name: 'foo' } }

          assert_equal('foo', promo_code_list.reload.name)
        end

        def test_bulk_upserts_promo_code_lists
          assert_difference 'Pricing::Discount::CodeList.count', 10 do
            patch admin_api.bulk_promo_code_lists_path,
              params: { promo_code_lists: [@sample_attributes] * 10 }
          end
        end

        def test_destroys_promo_code_lists
          promo_code_list = create_code_list

          assert_difference 'Pricing::Discount::CodeList.count', -1 do
            delete admin_api.promo_code_list_path(promo_code_list.id)
          end
        end
      end
    end
  end
end
