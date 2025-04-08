class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: [:zoom]

  def zoom
    request_body = request.raw_post

    unless ZoomWebhookService.valid_signature?(request.headers, request_body)
      Rails.logger.warn "[ZoomWebhook] Signature check failed"
      return head :unauthorized
    end

    payload = JSON.parse(request_body)
    event_type = payload["event"]
    recording_data = payload.dig("payload", "object")

    if event_type == "recording.completed"
      ProcessZoomRecordingJob.perform_later(recording_data, event_type)
    end

    head :ok
  end
end
