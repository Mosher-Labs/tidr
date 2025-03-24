class UsersController < ApplicationController
  def index
    @zoom_connected = current_user.zoom_access_token.present?
    @calendly_connected = current_user.calendly_access_token.present?

    if @calendly_connected
      @meetings = fetch_upcoming_events(current_user.calendly_access_token)
    else
      @meetings = []
    end
  end

  private

  def fetch_upcoming_events(access_token)
    uri = URI.parse("https://api.calendly.com/scheduled_events?status=active&sort=start_time:asc")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body) rescue {}

    data["collection"] || [] # Returns an array of upcoming meetings
  end
end
