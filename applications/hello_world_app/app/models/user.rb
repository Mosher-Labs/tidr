require "net/http"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def refresh_calendly_token!
    return unless calendly_refresh_token && calendly_token_expires_at < Time.current + 5.minutes

    uri = URI.parse("https://auth.calendly.com/oauth/token")
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
      client_id: ENV["CALENDLY_CLIENT_ID"],
      client_secret: ENV["CALENDLY_CLIENT_SECRET"],
      refresh_token: calendly_refresh_token,
      grant_type: "refresh_token"
    )

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body) rescue {}

    if data["access_token"]
      update(
        calendly_access_token: data["access_token"],
        calendly_refresh_token: data["refresh_token"],
        calendly_token_expires_at: Time.current + data["expires_in"].to_i.seconds
      )
    end
  end
end
