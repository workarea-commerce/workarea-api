$:.push File.expand_path('../lib', __FILE__)

require 'workarea/api/version'

Gem::Specification.new do |s|
  s.name        = 'workarea-api'
  s.version     = Workarea::Api::VERSION
  s.authors     = ['Ben Crouse', 'Curt Howard']
  s.email       = ['bcrouse@weblinc.com', 'choward@weblinc.com']
  s.homepage    = 'https://github.com/workarea-commerce/workarea-api'
  s.summary     = 'API for the Workarea commerce platform'
  s.description = 'HTTP API Rails Engine of the Workarea ecommerce platform'

  s.files = `git ls-files`.split("\n")

  s.license = 'Business Software License'

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'workarea', '~> 3.x', '>= 3.4.x'
  s.add_dependency 'workarea-api-storefront', Workarea::Api::VERSION
  s.add_dependency 'workarea-api-admin', Workarea::Api::VERSION
  s.add_dependency 'raddocs', '~> 2.2.0'
  s.add_dependency 'swagger-blocks', '~> 2.0.2'
end
