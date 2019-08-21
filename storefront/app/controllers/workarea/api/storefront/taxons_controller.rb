module Workarea
  module Api
    module Storefront
      class TaxonsController < Api::Storefront::ApplicationController
        before_action :cache_page

        def show
          @taxon = Navigation::Taxon.find(params[:id])

          unless @taxon.active?
            raise Mongoid::Errors::DocumentNotFound.new(
              Navigation::Taxon,
              id: params[:id]
            )
          end
        end
      end
    end
  end
end
