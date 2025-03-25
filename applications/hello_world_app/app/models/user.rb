require "net/http"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # TODO: Add validations for Zoom
  validates :calendly_access_token, presence: true, if: -> { calendly_refresh_token.present? }
  validates :calendly_refresh_token, presence: true, if: -> { calendly_access_token.present? }
  validates :calendly_expires_at, presence: true, if: -> { calendly_access_token.present? }
end
