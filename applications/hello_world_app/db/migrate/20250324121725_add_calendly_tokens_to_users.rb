class AddCalendlyTokensToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :calendly_access_token, :string
    add_column :users, :calendly_refresh_token, :string
    add_column :users, :calendly_token_expires_at, :datetime
  end
end
