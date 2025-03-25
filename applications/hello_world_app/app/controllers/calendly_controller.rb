require "net/http"
require "uri"
require "json"

class CalendlyController < ApplicationController
  before_action :authenticate_user!

  CALENDLY_AUTH_URL = "https://auth.calendly.com/oauth/authorize"
  CALENDLY_TOKEN_URL = "https://auth.calendly.com/oauth/token"
  CALENDLY_CLIENT_ID = ENV["CALENDLY_CLIENT_ID"]
  CALENDLY_REDIRECT_URI = ENV["CALENDLY_REDIRECT_URI"]
  CALENDLY_CLIENT_SECRET = ENV["CALENDLY_CLIENT_SECRET"]

  def connect
    redirect_to "#{CALENDLY_AUTH_URL}?client_id=#{CALENDLY_CLIENT_ID}&response_type=code&redirect_uri=#{CALENDLY_REDIRECT_URI}", allow_other_host: true
  end

  def callback
    if params[:error]
      flash[:alert] = "Calendly Authentication Failed: #{params[:error_description]}"
      redirect_to root_path and return
    end

    code = params[:code]
    token_response = exchange_code_for_token(code)

    if token_response["access_token"]
      current_user.update(
        calendly_access_token: token_response["access_token"],
        calendly_refresh_token: token_response["refresh_token"],
        calendly_expires_at: Time.current + token_response["expires_in"].to_i.seconds # Use `calendly_expires_at`
      )

      # Fetch and store user info
      calendly_user = fetch_calendly_user(token_response["access_token"])
      if calendly_user
        current_user.update(
          calendly_user_uri: calendly_user["uri"],
          calendly_user_name: calendly_user["name"],
          calendly_user_email: calendly_user["email"]
        )
        flash[:notice] = "Connected to Calendly as #{calendly_user["name"]} (#{calendly_user["email"]})!"
      else
        flash[:alert] = "Calendly connected, but we couldn't retrieve user details."
      end
    else
      flash[:alert] = "Failed to authenticate with Calendly."
    end

    redirect_to root_path
  end

  private

  def exchange_code_for_token(code)
    uri = URI.parse(CALENDLY_TOKEN_URL)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
      client_id: CALENDLY_CLIENT_ID,
      client_secret: CALENDLY_CLIENT_SECRET,
      code: code,
      grant_type: "authorization_code",
      redirect_uri: CALENDLY_REDIRECT_URI
    )

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    JSON.parse(response.body) rescue {}
  end

  def fetch_calendly_user(access_token)
    uri = URI.parse("https://api.calendly.com/users/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body) rescue {}

    data["resource"] # Returns user details if successful
  end
end
