module Workarea
  module Api
    module Storefront
      module CheckoutsHelper
        def checkout_step_name(klass)
          klass.name.demodulize.underscore
        end
      end
    end
  end
end
