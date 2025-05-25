# frozen_string_literal: true
#
# Feature: Zoom Connect
#   As an authenticated user
#   I want to connect my Zoom account
#   So that I can sync my meetings and recordings
#
#   Scenario: Connect Zoom account successfully
#     Given I am logged in
#     And I am on the dashboard
#     When I click "Connect Zoom"
#     And I authorize the app with Zoom
#     Then I should see "Zoom connected successfully!"
#     And my Zoom tokens and profile info should be stored

require 'rails_helper'

RSpec.describe 'Zoom connect', type: :system do
  let(:zoom_email) { Faker::Internet.email }
  let(:zoom_user_id) { "abcd1234" }
  let!(:user) { create(:user) }

  before do
    login_as(user)
  end

  it 'shows the connect to Zoom button' do
    visit root_path
    expect(page).to have_content('Dashboard')
    expect(page).to have_link('Connect Zoom')
  end

  context 'when connecting to Zoom' do
    before do
      # Stub Zoom OAuth token exchange
      stub_request(:post, "https://zoom.us/oauth/token")
        .to_return(
          status: 200,
          body: {
            access_token: "fake_zoom_access_token",
            refresh_token: "fake_zoom_refresh_token",
            expires_in: 3600,
            token_type: "bearer"
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      # Stub Zoom user info fetch
      stub_request(:get, "https://api.zoom.us/v2/users/me")
        .to_return(
          status: 200,
          body: {
            id: zoom_user_id,
            email: zoom_email,
            first_name: "Zoomy",
            last_name: "User"
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it 'initiates the OAuth flow and handles the callback' do
      visit root_path
      expect(page).to have_content('Dashboard')
      click_link('Connect Zoom')

      # Simulate Zoom redirect/callback
      visit zoom_callback_path(code: "mockzoomcode123")

      expect(page).to have_content("Zoom connected successfully!")
    end
  end
end
