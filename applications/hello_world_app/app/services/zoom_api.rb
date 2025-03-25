require "base64"
require "json"
require "net/http"
require "uri"

module ZoomApi
  ZOOM_AUTHORIZE_URL = "https://zoom.us/oauth/authorize"
  ZOOM_TOKEN_URL = "https://zoom.us/oauth/token"
  ZOOM_USER_INFO_URL = "https://api.zoom.us/v2/users/me"

  # TODO: Change variable names to include zoom
  CLIENT_ID = ENV["ZOOM_CLIENT_ID"]
  CLIENT_SECRET = ENV["ZOOM_CLIENT_SECRET"]
  REDIRECT_URI = ENV["ZOOM_REDIRECT_URI"]

  def self.authorization_url
    "#{ZOOM_AUTHORIZE_URL}?response_type=code&client_id=#{CLIENT_ID}&redirect_uri=#{REDIRECT_URI}"
  end

  def self.exchange_code_for_token(code)
    uri = URI.parse(ZOOM_TOKEN_URL)
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Basic #{Base64.strict_encode64("#{CLIENT_ID}:#{CLIENT_SECRET}")}"
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.set_form_data({
      grant_type: "authorization_code",
      code: code,
      redirect_uri: REDIRECT_URI
    })

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    body = JSON.parse(response.body) rescue {}
    Rails.logger.debug "Zoom OAuth Response: #{body.inspect}"
    body
  end

  def self.get_user_info(access_token)
    uri = URI.parse(ZOOM_USER_INFO_URL)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body) rescue {}
  end
end
