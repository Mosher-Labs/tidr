class AddZoomEmailToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :zoom_email, :string
  end
end
