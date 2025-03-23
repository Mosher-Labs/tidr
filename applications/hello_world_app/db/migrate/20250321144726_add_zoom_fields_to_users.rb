class AddZoomFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :zoom_host_id, :string
    add_column :users, :zoom_access_token, :string
  end
end
