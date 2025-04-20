require "open-uri"
require "httparty"

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

    filename = "/zoom-#{recording_data["id"]}.mp4"

    # Stream download from Zoom and upload to Dropbox
    open(recording_data["download_url"], "rb",
         "Authorization" => "Bearer #{user.zoom_access_token}") do |file_stream|
      dropbox_upload(file_stream, filename, user.dropbox_access_token)
    end

    rec.update!(status: "uploaded", dropbox_path: filename)
  rescue => e
    rec.update(status: "failed") if rec&.persisted?
    raise e
  end

  private

  def dropbox_upload(file_stream, dropbox_path, access_token)
    url = "https://content.dropboxapi.com/2/files/upload"

    response = HTTParty.post(url,
      headers: {
        "Authorization" => "Bearer #{access_token}",
        "Dropbox-API-Arg" => {
          path: dropbox_path,
          mode: "add",
          autorename: true,
          mute: false
        }.to_json,
        "Content-Type" => "application/octet-stream"
      },
      body: file_stream.read
    )

    unless response.success?
      Rails.logger.error "❌ Dropbox upload failed: #{response.code} - #{response.body}"
      raise "Dropbox upload failed"
    end
  end
end
