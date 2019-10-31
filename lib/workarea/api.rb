require 'responders'
require 'raddocs'

require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'

module Workarea
  module Api
    mattr_accessor :routing_constraints
  end
end

require 'workarea/api/engine'
require 'workarea/api/version'

require 'workarea/api/admin'
require 'workarea/api/storefront'
require 'workarea/api/documentation'
require 'workarea/api/integration_test'
