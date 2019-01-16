class Grant < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true
end
