module Workarea
  module Api
    module Storefront
      class ContactsController < Api::Storefront::ApplicationController
        def create
          inquiry = Inquiry.create!(inquiry_params)
          Workarea::Storefront::InquiryMailer.created(inquiry.id.to_s).deliver_later

          render(json: { inquiry: inquiry })
        end

        private

        def inquiry_params
          params.permit(:name, :email, :order_id, :subject, :message)
        end
      end
    end
  end
end
