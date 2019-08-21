module Workarea
  module Api
    module Admin
      module DateFiltering
        extend ActiveSupport::Concern
        included do
          index({ updated_at: 1 })
          index({ created_at: 1 })

          scope :by_updated_at, ->(starts_at:, ends_at:) do
            query = criteria
            query = query.where(:updated_at.gte => starts_at) unless starts_at.nil?
            query = query.where(:updated_at.lte => ends_at) unless ends_at.nil?
            query
          end

          scope :by_created_at, ->(starts_at:, ends_at:) do
            query = criteria
            query = query.where(:created_at.gte => starts_at) unless starts_at.nil?
            query = query.where(:created_at.lte => ends_at) unless ends_at.nil?
            query
          end
        end
      end
    end
  end
end
