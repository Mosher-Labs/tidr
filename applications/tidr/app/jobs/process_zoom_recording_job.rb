class ProcessZoomRecordingJob < ApplicationJob
  queue_as :default

  def perform(recording_data, event)
    Rails.logger.info "📦 ZoomWebhookJob started with: #{recording_data.inspect}"

    # Example logic
    case event
    when "recording.completed"
      # Do something like fetch the recording
      Rails.logger.info "🎥 Recording completed! Start processing..."

      user = User.find_by(zoom_user_id: recording_data["host_id"])
      return unless user

      ZoomRecording.find_or_create_by!(recording_id: recording_data["id"]) do |rec|
        rec.user = user
        rec.topic = recording_data["topic"]
        rec.start_time = recording_data["start_time"]
        rec.duration = recording_data["duration"]
        rec.download_url = recording_data["download_url"]
        rec.status = "completed"
      end
    else
      Rails.logger.warn "❓ Unknown event: #{event}"
    end
  end
end
