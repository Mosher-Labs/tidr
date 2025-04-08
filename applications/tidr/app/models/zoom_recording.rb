class ZoomRecording < ApplicationRecord
  belongs_to :user

  validates :recording_id, uniqueness: true
end
