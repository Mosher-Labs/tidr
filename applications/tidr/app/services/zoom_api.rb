require "base64"
require "json"
require "net/http"
require "uri"

module ZoomApi
  ZOOM_AUTHORIZE_URL = "https://zoom.us/oauth/authorize"
  ZOOM_TOKEN_URL = "https://zoom.us/oauth/token"
  ZOOM_BASE_URL = "https://api.zoom.us/v2"
  ZOOM_USER_INFO_URL = "#{ZOOM_BASE_URL}/users/me"

  ZOOM_CLIENT_ID = ENV["ZOOM_CLIENT_ID"]
  ZOOM_CLIENT_SECRET = ENV["ZOOM_CLIENT_SECRET"]
  ZOOM_REDIRECT_URI = ENV["ZOOM_REDIRECT_URI"]

  def self.authorization_url
    "#{ZOOM_AUTHORIZE_URL}?response_type=code&client_id=#{ZOOM_CLIENT_ID}&redirect_uri=#{ZOOM_REDIRECT_URI}"
  end

  def self.exchange_code_for_token(code)
    uri = URI.parse(ZOOM_TOKEN_URL)
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Basic #{Base64.strict_encode64("#{ZOOM_CLIENT_ID}:#{ZOOM_CLIENT_SECRET}")}"
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.set_form_data({
      grant_type: "authorization_code",
      code: code,
      redirect_uri: ZOOM_REDIRECT_URI
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

  def self.fetch_recordings(user, from: nil, to: nil)
    return [] unless user.zoom_access_token

    from ||= (Time.now.utc - 1.year).strftime("%Y-%m-%d")
    to ||= Time.now.utc.strftime("%Y-%m-%d")

    recordings = []
    current_start_date = Date.parse(from)

    while current_start_date < Date.parse(to)
      current_end_date = [current_start_date + 29, Date.parse(to)].min # Ensure we don't exceed 'to' date

      # Call Zoom API for the current 30-day chunk
      chunk_recordings = fetch_recordings_chunk(user, current_start_date.strftime("%Y-%m-%d"), current_end_date.strftime("%Y-%m-%d"))

      # Add results to the list
      recordings.concat(chunk_recordings)

      # Move to the next 30-day period
      current_start_date = current_end_date + 1
    end

    recordings
  end

  private

  # Fetch recordings for a specific 30-day chunk
  def self.fetch_recordings_chunk(user, from_date, to_date)
    uri = URI.parse("#{ZOOM_BASE_URL}/users/#{user.zoom_user_id}/recordings?from=#{from_date}&to=#{to_date}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{user.zoom_access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body) rescue {}

    # Extract recordings
    (data["meetings"] || []).map do |recording|
      {
        name: recording["topic"],
        start_time: recording["start_time"],
        recording_url: recording["share_url"]
      }
    end
  end
end
