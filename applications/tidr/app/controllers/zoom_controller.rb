class ZoomController < ApplicationController
  before_action :authenticate_user!

  # Step 1: Redirect user to Zoom for OAuth approval
  def connect
    redirect_to ZoomApi.authorization_url, allow_other_host: true
  end

  # Step 2: Handle Zoom's redirect and store user Zoom info
  def callback
    code = params[:code]
    Rails.logger.debug "Received Zoom OAuth Code: #{code}"

    if code.blank?
      flash[:alert] = "Authorization code missing"
      redirect_to root_path and return
    end

    response = ZoomApi.exchange_code_for_token(code)
    Rails.logger.debug "Zoom API Response: #{response.inspect}"

    if response.nil? || !response.is_a?(Hash) || response["access_token"].nil?
      Rails.logger.error "Zoom OAuth Error: #{response.inspect}"
      flash[:alert] = "Failed to connect to Zoom. Check logs for details."
      redirect_to root_path and return
    end

    access_token = response["access_token"]
    refresh_token = response["refresh_token"]

    # Fetch the user's Zoom ID
    zoom_user_info = ZoomApi.get_user_info(access_token)
    zoom_host_id = zoom_user_info["id"] if zoom_user_info.is_a?(Hash)
    current_user.update(zoom_host_id: zoom_host_id, zoom_access_token: access_token, zoom_email: zoom_user_info["email"], zoom_user_id: zoom_user_info["id"])

    if access_token && zoom_host_id
      current_user.update(zoom_host_id: zoom_host_id, zoom_access_token: access_token, zoom_refresh_token: refresh_token)
      flash[:notice] = "Zoom connected successfully!"
    else
      flash[:alert] = "Failed to retrieve Zoom user information."
    end

    redirect_to root_path
  end
end
