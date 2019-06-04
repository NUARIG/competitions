# frozen_string_literal: true

class Constraint < ApplicationRecord
  include ActiveModel::Validations

  has_many :constraint_questions
  has_many :questions, through: :constraint_questions

  enum value_type: {
    integer: 'integer',
    float: 'float'
  }, _suffix: true

  validates :name, presence: true
  validates :name, length: { minimum: 4 }
  validate :default_is_a_value_type

  private

  def default_is_a_value_type
    return if default.nil? || default == 'nil'

    send("default_is_#{value_type}")
  end

  def default_is_integer
    unless Integer(default, exception: false)
      errors.add(:default, 'value must be an integer.')
    end
  end

  def default_is_float
    unless Float(default, exception: false)
      errors.add(:default, 'value must be a number.')
    end
  end
end
