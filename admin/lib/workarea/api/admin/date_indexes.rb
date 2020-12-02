
module Workarea
  module Api
    module Admin
      module DateIndexes
        extend self

        # We do this separately from the DateFiltering module to ensure
        # this happens after a model has defined all of its normal indexes. This
        # prevents the date filtering indexes from applying before explicity
        # defined indexes for models that could include options like a TTL.
        def load
          ::Mongoid.models.each do |model|
            if model < ApplicationDocument
              model.index({ updated_at: 1 })
              model.index({ created_at: 1 })
            end
          end
        end
      end
    end
  end
end
