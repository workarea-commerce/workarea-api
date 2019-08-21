module Workarea
  module Api
    module Storefront
      module ContentBlocksHelper
        def block_data_with_urls(block)
          data = block.data.deep_dup

          block.type.fields.inject(data) do |data, field|
            value = block.data[field.slug.to_s]

            if field.type == :asset && value.present?
              asset =
                begin
                  Content::Asset.find(value)
                rescue
                  Content::Asset.placeholder
                end

              data["#{field.slug.to_s}_url"] = url_to_content_asset(asset)
            end

            data
          end
        end

        def render_block_to_string(block)
          Workarea::Storefront::ApplicationController.render(
            template: 'workarea/storefront/content_blocks/show',
            layout: false,
            assigns: {
              block: Workarea::Storefront::ContentBlockViewModel.wrap(block)
            }
          )
        end
      end
    end
  end
end
