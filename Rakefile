#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake/testtask'
require 'date'

load 'rails/test_unit/testing.rake'
load 'workarea/changelog.rake'

GEMS = %w(admin storefront).freeze
ROOT_DIR = Dir.pwd

GEMS.each do |gem|
  Rake::TestTask.new("#{gem}_test") do |t|
    t.libs << "#{gem}/test"
    t.pattern = "#{gem}/test/**/*_test.rb"
    t.verbose = false
    t.warning = false
  end

  task "#{gem}_test_ci" do
    ENV['CI'] = 'true'
    ENV['JUNIT_PATH'] = "#{gem}/test/reports"

    $: << "#{gem}/test"

    Rails::TestUnit::Runner.rake_run(["#{gem}/test/**/*_test.rb"])
  end
end

Rake::Task['test'].clear
desc 'Run tests for all gems'
task :test do
  require 'rails/test_unit/reporter'

  $: << 'admin/test'
  $: << 'storefront/test'
  Rails::TestUnitReporter.executable = 'bin/rails test'

  # Override this to print a command that we rerun the test on failure
  Rails::TestUnitReporter.class_eval do
    def format_rerun_snippet(result)
      location, line = result.method(result.name).source_location
      rel_path = relative_path_for(location)

      GEMS.each do |gem|
        if rel_path.include?(gem)
          return "cd #{gem} && bin/rails test #{rel_path}:#{line}"
        end
      end

      "#{executable} #{rel_path}:#{line}"
    end
  end

  Rails::TestUnit::Runner.rake_run(GEMS.map { |g| "#{g}/test" })
end

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'workarea/api/version'

desc "Release version #{Workarea::Api::VERSION} of the gem"
task :release do
  host = "https://#{ENV['BUNDLE_GEMS__WEBLINC__COM']}@gems.weblinc.com"

  #
  # Updating changelog
  #
  #
  #Rake::Task['workarea:changelog'].execute
  #system 'git add CHANGELOG.md'
  #system 'git commit -m "Update CHANGELOG"'
  #system 'git push origin HEAD'

  #
  # Build documentation
  #
  #
  system 'GENERATE_API_DOCS=true bundle exec rake test && git add doc && git commit -am "Update documentation" && git push origin HEAD'

  #
  # Build gem files
  #
  #
  GEMS.each do |gem|
    Dir.chdir("#{ROOT_DIR}/#{gem}")
    system "gem build workarea-api-#{gem}.gemspec"
  end

  Dir.chdir(ROOT_DIR)
  system 'gem build workarea-api.gemspec'

  #
  # Push gem files
  #
  #
  puts 'Pushing gems...'
  GEMS.each do |gem|
    system "gem push #{gem}/workarea-api-#{gem}-#{Workarea::Api::VERSION}.gem"
    system "gem push #{gem}/workarea-api-#{gem}-#{Workarea::Api::VERSION}.gem --host #{host}"
  end
  system "gem push workarea-api-#{Workarea::Api::VERSION}.gem"
  system "gem push workarea-api-#{Workarea::Api::VERSION}.gem --host #{host}"
  system 'Tagging git...'
  system "git tag -a v#{Workarea::Api::VERSION} -m 'Tagging #{Workarea::Api::VERSION}'"
  system 'git push --tags'

  #
  # Clean up
  #
  #
  puts 'Cleaning up...'
  GEMS.each do |gem|
    system "rm #{gem}/workarea-api-#{gem}-#{Workarea::Api::VERSION}.gem"
  end
  system "rm workarea-api-#{Workarea::Api::VERSION}.gem"
end
