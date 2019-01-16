class User < ApplicationRecord
  belongs_to :organization

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
end
