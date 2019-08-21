require File.expand_path('../../lib/workarea/api/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'workarea-api-storefront'
  s.version     = Workarea::Api::VERSION
  s.authors     = ['Curt Howard']
  s.email       = ['choward@weblinc.com']
  s.homepage    = 'http://www.workarea.com'
  s.summary     = 'Storefront API for the Workarea commerce platform'
  s.description = 'Storefront HTTP API Rails Engine of the Workarea ecommerce platform'

  s.files = `git ls-files`.split("\n")

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'workarea', '~> 3.x', '>= 3.2.x'
  s.add_dependency 'responders', '~> 2.4.0'
end
