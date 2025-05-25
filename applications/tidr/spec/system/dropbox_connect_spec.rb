# Feature: Dropbox integration
#   As an authenticated user
#   I want to connect my Dropbox account
#   So I can sync files

require 'rails_helper'

RSpec.describe 'Dropbox connect', type: :system do
  let(:email) { Faker::Internet.email }
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  it 'shows the connect to Dropbox button' do
    visit root_path
    expect(page).to have_content('Dashboard')
    expect(page).to have_link('Connect Dropbox')
  end

  context 'when connecting to Dropbox' do
    before do
      stub_request(:post, "https://api.dropboxapi.com/oauth2/token")
        .to_return(
          status: 200,
          body: {
            access_token: "fake_dropbox_access_token",
            refresh_token: "fake_dropbox_refresh_token",
            expires_in: 14400,
            token_type: "bearer",
            account_id: "dbid:FAKEID",
            dropbox_email: email
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      stub_request(:post, "https://api.dropboxapi.com/2/users/get_current_account")
        .to_return(
          status: 200,
          body: {
            email: email,
            account_id: "dbid:FAKEID"
            # ... any other fields your code expects ...
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it 'initiates the OAuth flow and handles the callback' do
      visit root_path
      expect(page).to have_content('Dashboard')
      click_link('Connect Dropbox')

      visit oauth_dropbox_callback_path(code: "abc123")

      expect(page).to have_content("You are connected to Dropbox as #{email}")

      user.reload

      expect(user.dropbox_access_token).to eq("fake_dropbox_access_token")
      expect(user.dropbox_refresh_token).to eq("fake_dropbox_refresh_token")
    end
  end
end
