# Feature: User authentication
#   As a registered user
#   I want to sign in and access my dashboard
#
#   Scenario: Visiting the site while logged out
#     Given a registered user exists
#     And I am logged out
#     When I visit the home page
#     Then I should see the sign in page
#
#   Scenario: Signing in with valid credentials
#     Given a registered user exists
#     And I am logged out
#     When I visit the sign in page
#     And I fill in my username and password
#     And I click "Sign In"
#     Then I should see the dashboard


require 'rails_helper'

RSpec.describe 'User authentication', type: :system do
  let(:password) { 'password123' }
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
  end
end
