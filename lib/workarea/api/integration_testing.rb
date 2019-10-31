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
        return unless Workarea::Api.routing_constraints.present?

        uri = URI.parse(host)

        Workarea::Api.routing_constraints.each do |constraint, value|
          uri.send("#{constraint}=", value)
        end

        host! uri.to_s
      end
    end
  end
end
