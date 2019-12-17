load 'rails/test_unit/testing.rake'

namespace :workarea do
  namespace :api do
    desc 'Generate Workarea API Documentation'
    task docs: %i[workarea:prepare] do
      roots = [Workarea::Core::Engine.root] +
                Workarea::Plugin.installed.map(&:root) +
                [Rails.root]

      ENV['GENERATE_API_DOCS'] = 'true'

      Rails::TestUnit::Runner.rake_run(
        roots
          .map { |r| FileList["#{r}/test/documentation/**/*_test.rb"] }
          .reduce(&:+)
      )
    end
  end
end
