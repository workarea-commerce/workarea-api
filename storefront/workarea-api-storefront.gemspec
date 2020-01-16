require File.expand_path('../../lib/workarea/api/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'workarea-api-storefront'
  s.version     = Workarea::Api::VERSION
  s.authors     = ['Ben Crouse']
  s.email       = ['bcrouse@workarea.com']
  s.homepage    = 'https://www.workarea.com'
  s.license     = 'Business Software License'
  s.summary     = 'Storefront JSON REST API for the Workarea Commerce Platform'
  s.description = 'This provides a storefront JSON REST API for the Workarea Commerce Platform. Useful for building apps, kiosks, etc.'

  s.files = `git ls-files`.split("\n")

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'workarea', '~> 3.x', '>= 3.2.x'
  s.add_dependency 'responders', '~> 3.0.0'
end
