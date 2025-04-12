# app/services/dropbox_api.rb

require "net/http"
require "uri"
require "json"
require "base64"
require "active_support/time"

module DropboxApi
  DROPBOX_CLIENT_ID = ENV["DROPBOX_CLIENT_ID"]
  DROPBOX_CLIENT_SECRET = ENV["DROPBOX_CLIENT_SECRET"]
  REDIRECT_URI = ENV["DROPBOX_REDIRECT_URI"] || "http://localhost:3000/oauth/dropbox/callback"

  DROPBOX_AUTH_URL = "https://www.dropbox.com/oauth2/authorize"
  DROPBOX_TOKEN_URL = "https://api.dropboxapi.com/oauth2/token"

  def self.authorization_url
    "#{DROPBOX_AUTH_URL}?response_type=code&client_id=#{DROPBOX_CLIENT_ID}&redirect_uri=#{REDIRECT_URI}&token_access_type=offline"
  end

  def self.exchange_code_for_token(code)
    uri = URI(DROPBOX_TOKEN_URL)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data({
      code: code,
      grant_type: "authorization_code",
      client_id: DROPBOX_CLIENT_ID,
      client_secret: DROPBOX_CLIENT_SECRET,
      redirect_uri: REDIRECT_URI
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    JSON.parse(response.body)
  end

  def self.refresh_access_token(user)
    return unless user.dropbox_refresh_token

    uri = URI(DROPBOX_TOKEN_URL)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data({
      grant_type: "refresh_token",
      refresh_token: user.dropbox_refresh_token,
      client_id: DROPBOX_CLIENT_ID,
      client_secret: DROPBOX_CLIENT_SECRET
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body)

    Rails.logger.info "🔐 Dropbox token_data: #{token_data.inspect}"
    if data["access_token"]
      Rails.logger.info "🔐 Dropbox access_token: #{data["access_token"].inspect}"
      dropbox_token_expires_at = data["expires_in"] ? Time.current + data["expires_in"].to_i.seconds : nil
      user.update!(
        dropbox_access_token: data["access_token"],
        dropbox_token_expires_at: dropbox_token_expires_at
      )
    else
      Rails.logger.warn("Failed to refresh Dropbox token: #{data}")
    end
  end

  def self.get_account_info(access_token)
    uri = URI.parse("https://api.dropboxapi.com/2/users/get_current_account")

    # Create a truly empty POST request (no body at all)
    request = Net::HTTPGenericRequest.new(
      'POST',   # method
      true,     # request has request body
      true,     # response has response body
      uri.request_uri,
      {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      }
    )

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    Rails.logger.info "📨 Dropbox response: #{response.inspect}"

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      Rails.logger.error("❌ Dropbox get_account_info failed: #{response.code} - #{response.body}")
      raise "Failed to fetch Dropbox account info"
    end
  end
end
