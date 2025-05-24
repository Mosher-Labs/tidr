# Feature: Sign Up
#   As a new user
#   I want to sign up for an account
#   So that I can access the dashboard
#
#   Scenario: Signing up with valid credentials
#     Given I am a new visitor
#     When I visit the sign up page
#     And I fill in my email and password
#     And I submit the registration form
#     Then I should see the dashboard
#
#   Scenario: Cancelling registration
#     Given I am a new visitor
#     When I visit the sign up page
#     And I click "Cancel"
#     Then I should see the sign in page

require 'rails_helper'

RSpec.describe 'User registration', type: :system do
  it 'allows a new user to register and see the dashboard' do
    visit new_user_registration_path
    email    = Faker::Internet.email
    password = Faker::Internet.password(min_length: 12)

    fill_in 'Email', with: email
    fill_in 'Password', with: password
    fill_in 'Confirm Password', with: password
    click_button 'Sign Up'

    expect(page).to have_content('Dashboard')
  end

  it 'allows a new user to attempt to register and cancel' do
    visit new_user_registration_path

    click_link 'Cancel'

    expect(page).to have_content('Sign In')
  end
end
