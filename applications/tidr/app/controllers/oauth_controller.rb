class OauthController < ApplicationController
  def dropbox
    code = params[:code]
    token_data = DropboxApi.exchange_code_for_token(code)

    access_token = token_data["access_token"]
    Rails.logger.info "8====> #{token_data["access_token"]}"
    refresh_token = token_data["refresh_token"]
    expires_at = Time.current + token_data["expires_in"].seconds

    current_user.update!(
      dropbox_access_token: access_token,
      dropbox_refresh_token: refresh_token,
      dropbox_token_expires_at: expires_at,
    )

    account_info = DropboxApi.get_account_info(access_token)
    email = account_info["email"]

    current_user.update!(
      dropbox_email: email
    )

    redirect_to root_path, notice: "You are connected to Dropbox as #{email}"
  end
end
