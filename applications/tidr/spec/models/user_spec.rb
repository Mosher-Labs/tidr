require "rails_helper"

RSpec.describe User, type: :model do
  # TODO: Setup a user with random data, try ffactory
  subject(:user) { described_class.new(email: "test@example.com", password: "password123") }

  describe "Devise validations" do
    it "is valid with a valid email and password" do
      expect(user).to be_valid
    end

    it "is invalid without an email" do
      user.email = nil
      expect(user).not_to be_valid
    end

    it "is invalid without a password" do
      user.password = nil
      expect(user).not_to be_valid
    end
  end

  describe "Calendly token validations" do
    it "requires access_token if refresh_token is present" do
      user.calendly_refresh_token = "refresh"
      expect(user).not_to be_valid
      expect(user.errors[:calendly_access_token]).to include("can't be blank")
    end

    it "requires refresh_token if access_token is present" do
      user.calendly_access_token = "access"
      expect(user).not_to be_valid
      expect(user.errors[:calendly_refresh_token]).to include("can't be blank")
    end

    it "requires expires_at if access_token is present" do
      user.calendly_access_token = "access"
      user.calendly_refresh_token = "refresh"
      expect(user).not_to be_valid
      expect(user.errors[:calendly_expires_at]).to include("can't be blank")
    end
  end

  describe "Dropbox token validations" do
    it "requires access_token if refresh_token is present" do
      user.dropbox_refresh_token = "refresh"
      expect(user).not_to be_valid
      expect(user.errors[:dropbox_access_token]).to include("can't be blank")
    end

    it "requires refresh_token if access_token is present" do
      user.dropbox_access_token = "access"
      expect(user).not_to be_valid
      expect(user.errors[:dropbox_refresh_token]).to include("can't be blank")
    end

    it "requires expires_at if access_token is present" do
      user.dropbox_access_token = "access"
      user.dropbox_refresh_token = "refresh"
      expect(user).not_to be_valid
      expect(user.errors[:dropbox_token_expires_at]).to include("can't be blank")
    end
  end

  describe "Zoom token validations" do
    it "requires access_token if refresh_token is present" do
      user.zoom_refresh_token = "refresh"
      expect(user).not_to be_valid
      expect(user.errors[:zoom_access_token]).to include("can't be blank")
    end

    it "requires refresh_token if access_token is present" do
      user.zoom_access_token = "access"
      expect(user).not_to be_valid
      expect(user.errors[:zoom_refresh_token]).to include("can't be blank")
    end

    it "requires expires_at if access_token is present" do
      user.zoom_access_token = "access"
      user.zoom_refresh_token = "refresh"
      expect(user).not_to be_valid
      expect(user.errors[:zoom_token_expires_at]).to include("can't be blank")
    end
  end
end
