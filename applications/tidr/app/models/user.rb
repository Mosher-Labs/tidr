require "net/http"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :calendly_access_token, presence: true, if: -> { calendly_refresh_token.present? }
  validates :calendly_refresh_token, presence: true, if: -> { calendly_access_token.present? }
  validates :calendly_expires_at, presence: true, if: -> { calendly_access_token.present? }
  validates :dropbox_access_token, presence: true, if: -> { dropbox_refresh_token.present? }
  validates :dropbox_refresh_token, presence: true, if: -> { dropbox_access_token.present? }
  validates :dropbox_token_expires_at, presence: true, if: -> { dropbox_access_token.present? }
  validates :zoom_access_token, presence: true, if: -> { zoom_refresh_token.present? }
  validates :zoom_refresh_token, presence: true, if: -> { zoom_access_token.present? }
  validates :zoom_token_expires_at, presence: true, if: -> { zoom_access_token.present? }
end
