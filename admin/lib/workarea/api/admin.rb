require 'responders'
require 'raddocs'
require 'swagger/blocks'

require 'workarea'
require 'workarea/admin'

module Workarea
  module Api
    module Admin
      def self.authenticate(email, password)
        user = User.find_for_login(email, password)
        user.try(:api_access?) || user.try(:super_admin?) ? user : nil
      end
    end
  end
end

require 'workarea/api/version'
require 'workarea/api/admin/engine'
require 'workarea/api/admin/swagger'
