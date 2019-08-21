module Workarea
  module Api
    module Storefront
      class SavedAddressesController < Api::Storefront::ApplicationController
        def index
          @addresses = current_user.addresses
        end

        def show
          @address = current_user.addresses.find(params[:id])
        end

        def create
          @address = current_user.addresses.create!(address_params)
          render :show
        end

        def update
          @address = current_user.addresses.find(params[:id])

          @address.update_attributes!(address_params)
          render :show
        end

        def destroy
          current_user.addresses.find(params[:id]).destroy
          head :no_content
        end

        private

        def address_params
          params.permit(*Workarea.config.address_attributes)
        end
      end
    end
  end
end
