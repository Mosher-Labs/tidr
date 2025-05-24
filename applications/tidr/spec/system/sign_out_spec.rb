# Feature: User Sign out
#   As a signed-in user
#   I want to sign out
#   So that my session is securely ended
#
#   Scenario: Signing out from the dashboard
#     Given I am a registered user
#     And I am signed in
#     When I click "Sign Out"
#     Then I should see the sign in page
#     And I should not see the dashboard

require 'rails_helper'

RSpec.describe 'User Sign out', type: :system do
  let(:password) { Faker::Internet.unique.password(min_length: 12) }
  let(:user) { create(:user, password: password) }

  before do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_button 'Sign In'
    expect(page).to have_content('Dashboard')
  end

  it 'signs the user out and shows the sign in page' do
    click_button 'Sign Out'
    expect(page).to have_content('Sign In')
    expect(page).not_to have_content('Dashboard') # Adjust as needed
  end
end
