# Make sure this file is required in rails_helper.rb
require 'capybara/rspec'

Capybara.server_host = '0.0.0.0'
Capybara.server_port = 3001 + ENV['TEST_ENV_NUMBER'].to_i
Capybara.app_host = "http://test:3000"

Capybara.register_driver :selenium_remote_firefox do |app|
  options = ::Selenium::WebDriver::Firefox::Options.new
  options.add_argument('--headless')
  options.add_argument('--width=1400')
  options.add_argument('--height=900')

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: ENV.fetch('SELENIUM_REMOTE_URL', 'http://selenium:4444/wd/hub'),
    capabilities: options
  )
end

Capybara.javascript_driver = :selenium_remote_firefox
