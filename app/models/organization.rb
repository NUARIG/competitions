class Organization < ApplicationRecord
  has_many :grants
  has_many :users

  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true

  validates_format_of :url, :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.(edu|org)?(\/.*)?\z/ix
end
