class AddZoomUserIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :zoom_user_id, :string
  end
end
