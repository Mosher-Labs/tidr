class ProcessZoomRecordingJob < ApplicationJob
  queue_as :default

  def perform(recording_data)
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
  end
end
