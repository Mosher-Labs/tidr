class AddCalendlyUserInfoToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :calendly_user_uri, :string
    add_column :users, :calendly_user_name, :string
    add_column :users, :calendly_user_email, :string
  end
end
