class UsersController < ApplicationController
  def index
    @zoom_connected = current_user.zoom_access_token.present?
    if @zoom_connected
      from_param = params[:from].is_a?(String) ? params[:from] : nil
      to_param = params[:to].is_a?(String) ? params[:to] : nil

      from_date = from_param ? Date.parse(from_param).strftime("%Y-%m-%d") : (Time.now.utc - 1.year).strftime("%Y-%m-%d")
      to_date = to_param ? Date.parse(to_param).strftime("%Y-%m-%d") : Time.now.utc.strftime("%Y-%m-%d")

      @zoom_recordings = ZoomApi.fetch_recordings(current_user, from: from_date, to: to_date)
    else
      @zoom_recordings = []
    end

    CalendlyApi.refresh_token(current_user) if current_user.calendly_access_token.present?
    @calendly_connected = current_user.calendly_access_token.present?
    if @calendly_connected
      @meetings = CalendlyApi.fetch_upcoming_events(current_user)
    else
      @meetings = []
    end
  end
end
