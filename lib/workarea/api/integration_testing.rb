module Workarea
  module Api
    # Integration testing support for API routes that have been
    # configured in the router to use constraints rather than the
    # default of using the same host for every request.
    module IntegrationTesting
      extend ActiveSupport::Concern

      included do
        setup :setup_host
      end

      private

      def setup_host
        return unless constrain_routes?

        uri = URI.parse(host)

        routing_constraints.each do |constraint, value|
          uri.send("#{constraint}=", value)
        end

        host! uri.to_s
      end

      def constrain_routes?
        routing_constraints.present? && self.class.name.include?('Workarea::Api')
      end
    end
  end
end
