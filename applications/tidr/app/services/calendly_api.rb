require "net/http"
require "json"
require "uri"

module CalendlyApi
  BASE_URL = "https://api.calendly.com"
  TOKEN_URL = "https://auth.calendly.com/oauth/token"

  CLIENT_ID = ENV["CALENDLY_CLIENT_ID"]
  CLIENT_SECRET = ENV["CALENDLY_CLIENT_SECRET"]

  # Refresh access token if expired
  def self.refresh_token(user)
    return unless user.calendly_refresh_token
    return unless user.calendly_expires_at && user.calendly_expires_at < Time.current + 5.minutes

    uri = URI.parse(TOKEN_URL)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      refresh_token: user.calendly_refresh_token,
      grant_type: "refresh_token"
    )

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body) rescue {}

    if data["access_token"]
      user.update(
        calendly_access_token: data["access_token"],
        calendly_refresh_token: data["refresh_token"], # Sometimes refreshed too
        calendly_expires_at: Time.current + data["expires_in"].to_i.seconds
      )
    else
      Rails.logger.error "Failed to refresh Calendly token: #{response.body}"
    end
  end

  # Fetch user info (needed to retrieve their meetings)
  def self.fetch_user_info(user)
    refresh_token(user)

    uri = URI.parse("#{BASE_URL}/users/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{user.calendly_access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body) rescue {}

    if data["resource"]
      # user.update(calendly_user_email: data["resource"]["email"])
      # return data["resource"]["email"]
      return data["resource"]["uri"]
    end

    nil
  end

  # Fetch upcoming meetings for the user
  def self.fetch_upcoming_events(user)
    refresh_token(user)
    user_uri = fetch_user_info(user)
    return [] if user_uri.nil?

    min_start_time = Time.now.utc.iso8601
    uri = URI.parse("#{BASE_URL}/scheduled_events?user=#{user_uri}&status=active&sort=start_time:asc&min_start_time=#{min_start_time}")

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{user.calendly_access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body) rescue {}

    # Rails.logger.debug "Calendly Events: #{data.inspect}"

    (data["collection"] || []).map do |event|
      event_uri = event["uri"].split("/").last()
      event_name = event["name"]

      guest_emails = (event["event_guests"] || []).map { |guest| guest["email"] }.compact
      # Rails.logger.debug "Calendly Emails: #{guest_emails.inspect}"
      invitee_emails = fetch_event_invitees(event_uri, user)
      # Rails.logger.debug "Invitee Emails: #{invitee_emails.inspect}"

      all_participant_emails = (guest_emails + invitee_emails).uniq

      start_time = DateTime.parse(event["start_time"]).strftime("%b %d, %Y %l:%M %p")
      end_time = DateTime.parse(event["end_time"]).strftime("%b %d, %Y %l:%M %p")

      {
        name: event_name,
        start_time: start_time,
        end_time: end_time,
        participants: all_participant_emails
      }
    end
  end

  # Fetch invitees for an event
  def self.fetch_event_invitees(event_uri, user)
    refresh_token(user)

    Rails.logger.debug "Fetching invitees for event URI: #{event_uri}"

    uri = URI.parse("#{BASE_URL}/scheduled_events/#{event_uri}/invitees")

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{user.calendly_access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body) rescue {}

    # Rails.logger.debug "Calendly Invitees Response: #{data.inspect}"

    invitees = data["collection"] || []
    invitees.map { |invitee| invitee["email"] }.compact
  end
end
