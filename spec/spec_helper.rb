# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
MIN_COVERAGE = 75
THRESHOLD_COVERAGE = 80
FAIL_BUILD_ON_LOW_COVERAGE = true

require 'simplecov'
SimpleCov.start 'rails' do
  at_exit do
    SimpleCov.result.format!
    if FAIL_BUILD_ON_LOW_COVERAGE and SimpleCov.result.covered_percent < MIN_COVERAGE
      $stderr.puts "Coverage is less than #{MIN_COVERAGE}%. Please try to keep test coverage above #{THRESHOLD_COVERAGE}%. Build has failed!"
      exit 1
    end

    if SimpleCov.result.covered_percent < THRESHOLD_COVERAGE
      $stderr.puts "Warning! Coverage is less than #{THRESHOLD_COVERAGE}%. Please try to keep test coverage above #{THRESHOLD_COVERAGE}%."
      exit 0
    end
  end
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'authlogic/test_case'
include Authlogic::TestCase

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Factory Girl verbosity
  config.include FactoryGirl::Syntax::Methods
end
