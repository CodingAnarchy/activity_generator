require "bundler/setup"
require "byebug"
require "activity_generator"
require 'active_support'
require "active_support/core_ext/numeric"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:suite) do
    puts "Output log located at #{ActivityGenerator::Logging.logfile}"
  end
end
