require File.expand_path('../../lib/workarea/api/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'workarea-api-admin'
  s.version     = Workarea::Api::VERSION
  s.authors     = ['Ben Crouse']
  s.email       = ['bcrouse@workarea.com']
  s.homepage    = 'https://www.workarea.com'
  s.license     = 'Business Software License'
  s.summary     = 'Admin JSON REST API for the Workarea Commerce Platform'
  s.description = 'This provides an admin JSON REST API for the Workarea Commerce Platform. Useful for managing the site, 3rd party integrations, etc.'

  s.files = `git ls-files`.split("\n")

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'workarea', '~> 3.x', '>= 3.5.x'
  s.add_dependency 'responders', '~> 3.0.0'
end
