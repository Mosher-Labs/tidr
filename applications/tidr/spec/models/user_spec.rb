require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "Devise validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }

    it "is valid with valid email and password" do
      expect(user).to be_valid
    end
  end

  describe "Calendly token validations" do
    it_behaves_like "a token-authenticated service",
                    service: :calendly,
                    access_token: :calendly_access_token,
                    refresh_token: :calendly_refresh_token,
                    expires_at: :calendly_expires_at
  end

  describe "Dropbox token validations" do
    it_behaves_like "a token-authenticated service",
                    service: :dropbox,
                    access_token: :dropbox_access_token,
                    refresh_token: :dropbox_refresh_token,
                    expires_at: :dropbox_token_expires_at
  end

  describe "Zoom token validations" do
    it_behaves_like "a token-authenticated service",
                    service: :zoom,
                    access_token: :zoom_access_token,
                    refresh_token: :zoom_refresh_token,
                    expires_at: :zoom_token_expires_at
  end
end
