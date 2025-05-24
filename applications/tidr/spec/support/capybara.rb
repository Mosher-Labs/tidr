require 'capybara/rspec'

Capybara.server_host = '0.0.0.0'
Capybara.server_port = ENV['PORT'].to_i + ENV['TEST_ENV_NUMBER'].to_i
Capybara.app_host = "http://test:" + ENV['PORT']

Capybara.register_driver :selenium_remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--window-size=1400,900')
  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: ENV.fetch('SELENIUM_REMOTE_URL', 'http://selenium:4444/wd/hub'),
    options: options
  )
end

Capybara.default_driver = :selenium_remote_chrome
Capybara.javascript_driver = :selenium_remote_chrome

# (Optional) For system specs:
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_remote_chrome
  end
end
