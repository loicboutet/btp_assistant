# frozen_string_literal: true

# AdminUser model for back-office users (Devise authentication)
# These are the administrators who manage the BTP Assistant platform,
# NOT the artisans who use it via WhatsApp.
#
# Artisans are represented by the User model (phone = identity)
class AdminUser < ApplicationRecord
  self.table_name = 'admins'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
