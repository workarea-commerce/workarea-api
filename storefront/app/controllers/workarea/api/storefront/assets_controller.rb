module Workarea
  module Api
    module Storefront
      class AssetsController < Api::Storefront::ApplicationController
        def show
          @asset = Content::Asset.find(params[:id])
        end
      end
    end
  end
end
