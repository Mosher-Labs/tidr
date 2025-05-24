# Feature: User authentication
#   As a registered user
#   I want to sign in and access my dashboard
#
#   Scenario: Visiting the site while signed out
#     Given a registered user exists
#     And I am signed out
#     When I visit the home page
#     Then I should see the sign in page
#
#   Scenario: Signing in with valid credentials
#     Given a registered user exists
#     And I am signed out
#     When I visit the sign in page
#     And I fill in my username and password
#     And I click "Sign In"
#     Then I should see the dashboard
#
#   Scenario: Signing in with 'Remember me' checked
#     Given I am a registered user
#     And I am logged out
#     When I visit the sign in page
#     And I fill in my email and password
#     And I check "Remember me"
#     And I click "Sign In"
#     Then I should see the dashboard
#     Then I should still be signed in
#     When I close my browser and reopen the site


require 'rails_helper'

RSpec.describe 'User authentication', type: :system do
  let(:password) { Faker::Internet.unique.password(min_length: 12) }
  let(:user) { create(:user, password: password) }

  before do
    user
    visit destroy_user_session_path if defined?(destroy_user_session_path)
  end

  context 'when visiting the site while logged out' do
    it 'shows the sign in page' do
      visit root_path
      expect(page).to have_content('Sign In')
    end
  end

  context 'when signing in with valid credentials' do
    it 'allows the user to sign in and see the dashboard' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      click_button 'Sign In'
      expect(page).to have_content('Dashboard')
    end

    it "remembers the user after closing and reopening the browser" do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      check 'Remember me'
      click_button 'Sign In'
      expect(page).to have_content('Dashboard')

      # Save the remember_me cookie value
      cookie = page.driver.browser.manage.cookie_named('remember_user_token')

      # Simulate closing the browser (clears all cookies)
      Capybara.reset_sessions!
      visit root_path

      # Restore the remember_me cookie
      if cookie
        page.driver.browser.manage.add_cookie(cookie)
        visit root_path
      end

      expect(page).to have_content('Dashboard')
    end
  end
end
