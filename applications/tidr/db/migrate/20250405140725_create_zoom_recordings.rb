class CreateZoomRecordings < ActiveRecord::Migration[8.0]
  def change
    create_table :zoom_recordings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :recording_id
      t.string :topic
      t.datetime :start_time
      t.integer :duration
      t.string :download_url
      t.string :status

      t.timestamps
    end
  end
end
