class ProcessZoomRecordingJob < ApplicationJob
  queue_as :default

  def perform(recording_data, event)
    return unless event == "recording.completed"

    user = User.find_by(zoom_user_id: recording_data["host_id"])
    return unless user

    rec = ZoomRecording.find_or_initialize_by(recording_id: recording_data["id"])
    rec.user = user
    rec.topic = recording_data["topic"]
    rec.start_time = recording_data["start_time"]
    rec.duration = recording_data["duration"]
    rec.download_url = recording_data["download_url"]
    rec.status = "processing"
    rec.save!

    # file = download_file(rec.download_url, user.zoom_access_token)
    # url = upload_to_s3(file, filename: "zoom-#{rec.recording_id}.mp4")

    # Stream from Zoom and upload directly to S3
    open(zoom_download_url, "rb") do |file_stream|
      s3_client.put_object(bucket: "s3-bucket", key: "zoom-#{rec.recording_id}.mp4", body: file_stream)
    end

    rec.update!(status: "uploaded", s3_url: url)
  rescue => e
    rec.update(status: "failed") if rec&.persisted?
    raise e
  end
end
