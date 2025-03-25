class UsersController < ApplicationController
  def index
    @zoom_connected = current_user.zoom_access_token.present?
    CalendlyApi.refresh_token(current_user) if current_user.calendly_access_token.present?
    @calendly_connected = current_user.calendly_access_token.present?

    if @calendly_connected
      @meetings = CalendlyApi.fetch_upcoming_events(current_user)
    else
      @meetings = []
    end
  end
end
