source 'https://rubygems.org'
git_source :github do |repo|
  "https://github.com/#{repo}.git"
end

# Declare your gem's dependencies in api.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]


gem 'workarea-api-admin', path: 'admin'
gem 'workarea-api-storefront', path: 'storefront'

# TODO: Not sure I actually need this, might just be fixing bugs with
# the Rails 6 upgrade, but it was necessary to get tests running.
gem 'workarea',
  github: 'workarea-commerce/workarea',
  branch: 'decorating-modules'

gem 'rails-decorators',
  github: 'workarea-commerce/rails-decorators',
  branch: 'decorating-modules'

gem 'teaspoon', github: 'jtapia/teaspoon', branch: 'chore/update-rails-6'
