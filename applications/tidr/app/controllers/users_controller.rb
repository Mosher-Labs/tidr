class UsersController < ApplicationController
  def index
    @dropbox_connected = current_user.dropbox_access_token.present?
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

  def disconnect_calendly
    current_user.update(
      calendly_access_token: nil,
      calendly_expires_at: nil,
      calendly_refresh_token: nil,
      calendly_token_expires_at: nil,
      calendly_user_email: nil,
      calendly_user_name: nil,
      calendly_user_uri: nil,
    )

    redirect_to users_path, notice: "Successfully disconnected from Calendly."
  end

  def disconnect_dropbox
    current_user.update(
      dropbox_access_token: nil,
      dropbox_token_expires_at: nil,
      dropbox_refresh_token: nil,
      dropbox_email: nil,
    )

    redirect_to users_path, notice: "Successfully disconnected from Dropbox."
  end

  def disconnect_zoom
    current_user.update(
      zoom_access_token: nil,
      zoom_email: nil,
      zoom_host_id: nil,
      zoom_refresh_token: nil,
      zoom_user_id: nil,
    )

    redirect_to users_path, notice: "Successfully disconnected from Zoom."
  end
end
