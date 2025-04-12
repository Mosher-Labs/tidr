class AddDropboxEmailToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :dropbox_email, :string
  end
end
