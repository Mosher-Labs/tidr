require 'rails_helper'

RSpec.describe ZoomRecording, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { FactoryBot.create(:zoom_recording) }

    it { is_expected.to validate_uniqueness_of(:recording_id) }

    it { is_expected.to validate_presence_of(:status) }

    it {
      is_expected.to validate_inclusion_of(:status).
        in_array(%w[pending processing uploaded failed])
    }

    it { is_expected.to validate_presence_of(:download_url) }

    it 'validates format of download_url' do
      should allow_value('https://zoom.us/recording.mp4').for(:download_url)
      should_not allow_value('not-a-url').for(:download_url)
    end

    it 'allows optional fields to be blank' do
      recording = build(:zoom_recording, topic: nil, start_time: nil, duration: nil)
      expect(recording).to be_valid
    end
  end
end
