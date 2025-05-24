# Feature: Password reset
#   As a registered user
#   I want to reset my password if I forget it
#   So that I can regain access to my account
#
#   Scenario: Requesting password reset
#     Given I am a registered user
#     And I am logged out
#     When I visit the forgot password page
#     And I fill in my email
#     And I submit the password reset form
#     Then I should see a confirmation me
#
#   Scenario: Cancelling password reset
#     Given I am a user
#     When I visit the password reset page
#     And I click "Cancel"
#     Then I should see the sign in page

require 'rails_helper'

RSpec.describe 'Password reset', type: :system do
  let!(:user)    { create(:user) }

  before do
    visit destroy_user_session_path if defined?(destroy_user_session_path)
  end

  it 'shows a confirmation after submitting the password reset form' do
    visit root_path

    click_link 'Forgot password?'

    expect(page).to have_content('Forgot Password?')

    fill_in 'Email', with: user.email
    click_button 'Send Reset Instructions'

    expect(page).to have_content('You will receive an email with instructions')
  end

  it 'allows a user to attempt to password reset and cancel' do
    visit root_path

    click_link 'Forgot password?'

    expect(page).to have_content('Forgot Password?')

    click_link 'Cancel'

    expect(page).to have_content('Sign In')
  end
end
