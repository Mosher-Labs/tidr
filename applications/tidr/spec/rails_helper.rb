require 'spec_helper'

# Verify we are in the test environment
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'shoulda/matchers'
require 'webmock/rspec'

# Allow connections to your Selenium host AND localhost
WebMock.disable_net_connect!(allow: ['selenium', 'localhost', '0.0.0.0', '127.0.0.1'])

require 'warden/test/helpers'
include Warden::Test::Helpers

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods

  config.include Warden::Test::Helpers
  config.after(:each, type: :system) { Warden.test_reset! }
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
