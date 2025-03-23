class AddZoomRefreshTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :zoom_refresh_token, :string
  end
end
