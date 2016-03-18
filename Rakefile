require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new
rescue LoadError
end

task :test, [:hosting_provider] do |t, args|
  unless args.hosting_provider
    fail "Must provide a hosting_provider (e.g. rake test[github])"
  end

  ENV['GIT_HOSTING_PROVIDER'] = args[:hosting_provider]
  Rake::Task[:spec].invoke()
end
