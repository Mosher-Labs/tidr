class AddZoomTokenExpiresAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :zoom_token_expires_at, :datetime
  end
end
