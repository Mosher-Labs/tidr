class ZoomRecording < ApplicationRecord
  belongs_to :user

  validates :recording_id, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[pending processing uploaded failed] }
  validates :download_url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
end
