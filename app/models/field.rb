class Field < ApplicationRecord
  validates :name, presence: true, length: { minimum: 4 }
  validates :help_text, length: { minimum: 4 }, allow_blank: true
end
