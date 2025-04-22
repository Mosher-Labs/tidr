require "rails_helper"

RSpec.describe ZoomRecording, type: :model do
  # TODO: Setup a user with random data, try ffactory
  let(:user) { User.create(email: "test@example.com", password: "password123") }

  # TODO: Setup a recording with random data, try ffactory
  subject do
    described_class.new(
      user: user,
      recording_id: "abc123"
    )
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:recording_id) }
  end

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is invalid with a duplicate recording_id" do
    described_class.create!(user: user, recording_id: "abc123")
    duplicate = described_class.new(user: user, recording_id: "abc123")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:recording_id]).to include("has already been taken")
  end
end
