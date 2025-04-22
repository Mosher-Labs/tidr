RSpec.shared_examples "a token-authenticated service" do |service:, access_token:, refresh_token:, expires_at:, expires_at_error: nil|
  let(:user) { build(:user) }

  it "requires access_token if refresh_token is present" do
    user[refresh_token] = "refresh"
    user[access_token] = nil
    expect(user).not_to be_valid
    expect(user.errors[access_token]).to include("can't be blank")
  end

  it "requires refresh_token if access_token is present" do
    user[access_token] = "access"
    user[refresh_token] = nil
    expect(user).not_to be_valid
    expect(user.errors[refresh_token]).to include("can't be blank")
  end

  it "requires expires_at if access_token is present" do
    user[access_token] = "access"
    user[refresh_token] = "refresh"
    user[expires_at] = nil
    expect(user).not_to be_valid
    expect(user.errors[expires_at]).to include("can't be blank")
  end
end
