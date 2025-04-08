# app/services/zoom_webhook_service.rb
require "openssl"
require "base64"

class ZoomWebhookService
  def initialize(payload)
    @event = payload["event"]
    @payload = payload["payload"]
  end

  def process
    case @event
    when "recording.completed"
      handle_recording_completed
    else
      Rails.logger.info "Unhandled Zoom webhook event: #{@event}"
    end
  end

  def self.valid_signature?(headers, request_body)
    secret_token = ENV["ZOOM_WEBHOOK_SECRET_TOKEN"]
    timestamp = headers["HTTP_X_ZM_REQUEST_TIMESTAMP"]
    signature_header = headers["HTTP_X_ZM_SIGNATURE"]

    return false if timestamp.nil? || signature_header.nil?

    message = "#{timestamp}#{request_body}"
    digest = OpenSSL::HMAC.digest("sha256", secret_token, message)
    expected_signature = "v0=#{Base64.strict_encode64(digest)}"

    ActiveSupport::SecurityUtils.secure_compare(expected_signature, signature_header)
  rescue => e
    Rails.logger.error "[ZoomWebhook] Exception in signature validation: #{e.message}"
    false
  end

  private

  def handle_recording_completed
    object = @payload["object"]
    host_email = object["host_email"]
    user = User.find_by(email: host_email)

    unless user
      Rails.logger.warn "No user found for Zoom host email: #{host_email}"
      return
    end

    ZoomApi.fetch_recordings(user, from: object["start_time"], to: object["end_time"])
  end
end
