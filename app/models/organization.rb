# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :grants
  has_many :users

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true

  validates_format_of :url, with: %r{\A(http|https)://[a-z0-9]+([\-\.]{1,3}[a-z0-9]+)*\.(edu|org|gov)?(/.*)?\z}ix
end
