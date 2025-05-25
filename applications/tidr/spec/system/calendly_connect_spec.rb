# Feature: Calendly Connect
#   As an authenticated user
#   I want to connect my Calendly account
#   So that I can sync my meetings and availability
#
#   Scenario: Connect Calendly account successfully
#     Given I am logged in
#     And I am on the dashboard
#     When I click "Connect Calendly"
#     And I authorize the app with Calendly
#     Then I should see "Connected to Calendly as <name> (<email>)!"
#     And my Calendly tokens and profile info should be stored

require 'rails_helper'

RSpec.describe 'Calendly connect', type: :system do
  let(:name) { "Test User" }
  let(:email) { "testuser@example.com" }
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  it 'shows the connect to Calendly button' do
    visit root_path
    expect(page).to have_content('Dashboard')
    expect(page).to have_link('Connect Calendly')
  end

  context 'when connecting to Calendly' do
    before do
      # Stub Calendly token exchange
      stub_request(:post, "https://auth.calendly.com/oauth/token")
        .to_return(
          status: 200,
          body: {
            access_token: "fake_calendly_access_token",
            refresh_token: "fake_calendly_refresh_token",
            expires_in: 3600,
            token_type: "bearer"
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      # Stub Calendly user info fetch
      stub_request(:get, "https://api.calendly.com/users/me")
        .to_return(
          status: 200,
          body: {
            resource: {
              uri: "https://api.calendly.com/users/ABC123",
              name: name,
              email: email
            }
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      stub_request(:get, /https:\/\/api\.calendly\.com\/scheduled_events.*/)
        .to_return(
          status: 200,
          body: { collection: [] }.to_json, # or whatever fake events your app expects
          headers: { "Content-Type" => "application/json" }
        )
    end

    it 'initiates the OAuth flow and handles the callback' do
      visit root_path
      expect(page).to have_content('Dashboard')
      click_link('Connect Calendly')

      # Simulate Calendly redirect/callback
      visit auth_calendly_callback_path(code: "mockcode123")

      expect(page).to have_content("Connected to Calendly as #{name} (#{email})!")

      user.reload
      expect(user.calendly_access_token).to eq("fake_calendly_access_token")
      expect(user.calendly_refresh_token).to eq("fake_calendly_refresh_token")
      expect(user.calendly_user_email).to eq(email)
      expect(user.calendly_user_name).to eq(name)
      expect(user.calendly_user_uri).to eq("https://api.calendly.com/users/ABC123")
    end
  end
end
