FactoryBot.define do
  factory :zoom_recording do
    user
    recording_id { SecureRandom.uuid }
    topic { 'My Zoom Meeting' }
    start_time { Time.now }
    duration { 60 }
    download_url { 'https://zoom.us/recording.mp4' }
    status { 'pending' }
  end
end
