module Workarea
  module Api
    module Storefront
      module ApplicationHelper
        def storefront_api_url_for(taxon)
          port = Rails.env.development? ? request.port : nil

          if taxon.url?
            taxon.url
          elsif taxon.navigable?
            send("#{taxon.resource_name}_url", taxon.navigable_slug, port: port)
          end
        end
      end
    end
  end
end
