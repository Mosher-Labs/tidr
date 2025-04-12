class AddDropboxToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :dropbox_access_token, :string
    add_column :users, :dropbox_refresh_token, :string
    add_column :users, :dropbox_token_expires_at, :datetime
  end
end
