# app/services/dropbox_api.rb

require "active_support/time"
require "base64"
require "json"
require "open3"
require "uri"

module DropboxApi
  DROPBOX_CLIENT_ID = ENV["DROPBOX_CLIENT_ID"]
  DROPBOX_CLIENT_SECRET = ENV["DROPBOX_CLIENT_SECRET"]
  REDIRECT_URI = ENV["DROPBOX_REDIRECT_URI"]
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

    Rails.logger.debug "🔐 Dropbox token_data: #{token_data.inspect}"
    if data["access_token"]
      dropbox_token_expires_at = data["expires_in"] ? Time.current + data["expires_in"].to_i.seconds : nil
      user.update!(
        dropbox_access_token: data["access_token"],
        dropbox_token_expires_at: dropbox_token_expires_at
      )
    else
      Rails.logger.warn("Failed to refresh Dropbox token: #{data}")
    end
  end

  # def self.get_account_info(access_token)
  #   curl_command = [
  #     "curl",
  #     "-s",  # silent mode (no progress)
  #     "-X", "POST",
  #     "https://api.dropboxapi.com/2/users/get_current_account",
  #     "-H", "Authorization: Bearer #{access_token}"
  #   ]
  #
  #   stdout, stderr, status = Open3.capture3(*curl_command)
  #
  #   Rails.logger.info "📨 Dropbox response: #{status.exitstatus} - #{stdout}"
  #
  #   if status.success?
  #     JSON.parse(stdout)
  #   else
  #     Rails.logger.error("❌ Dropbox get_account_info failed: #{stderr.presence || stdout}")
  #     raise "Failed to fetch Dropbox account info"
  #   end
  # end
  def self.get_account_info(access_token)
    uri = URI.parse("https://api.dropboxapi.com/2/users/get_current_account")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{access_token}"
    request.delete('Content-Type')
    request.body = nil

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      raise "Failed to fetch Dropbox account info"
    end
  end

  # def self.get_account_info(access_token)
  #   url = URI.parse("https://api.dropboxapi.com/2/users/get_current_account")
  #
  #   # Prepare the HTTP request
  #   request = Net::HTTP::Post.new(url)
  #   request["Authorization"] = "Bearer #{access_token}"
  #
  #   request.delete('Content-Type')
  #
  #   # Do NOT set the Content-Type header, and send no body at all
  #   request.body = nil  # Explicitly ensure there's no body
  #
  #   # Perform the HTTP request
  #   response = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
  #     http.request(request)
  #   end
  #
  #   Rails.logger.info "📨 Dropbox response: #{response.code} - #{response.body}"
  #
  #   if response.code.to_i == 200
  #     JSON.parse(response.body)
  #   else
  #     Rails.logger.error("❌ Dropbox get_account_info failed: #{response.code} - #{response.body}")
  #     raise "Failed to fetch Dropbox account info"
  #   end
  # end

  # def self.get_account_info(access_token)
  #   url = "https://api.dropboxapi.com/2/users/get_current_account"
  #
  #   response = HTTParty.post(url, headers: {
  #     "Authorization" => "Bearer #{access_token}"
  #   }, body: nil)
  #
  #   Rails.logger.info "📨 Dropbox response: #{response.code} - #{response.body}"
  #
  #   if response.code == 200
  #     JSON.parse(response.body)
  #   else
  #     Rails.logger.error("❌ Dropbox get_account_info failed: #{response.code} - #{response.body}")
  #     raise "Failed to fetch Dropbox account info"
  #   end
  # end

  # def self.get_account_info(access_token)
  #   uri = URI.parse("https://api.dropboxapi.com/2/users/get_current_account")
  #   request = Net::HTTP::Post.new(uri)
  #   request["Authorization"] = "Bearer #{access_token}"
  #   request["Content-Type"] = "application/json"
  #   request.body = "".to_json
  #
  #   response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  #     http.request(request)
  #   end
  #
  #   Rails.logger.info "📨 Dropbox response: #{response.inspect}"
  #
  #   if response.code.to_i == 200
  #     JSON.parse(response.body)
  #   else
  #     Rails.logger.error("❌ Dropbox get_account_info failed: #{response.code} - #{response.body}")
  #     raise "Failed to fetch Dropbox account info"
  #   end
  # end
end
