# frozen_string_literal: true

class TextQuestion < Question
  validate :validate_maximum_and_minimum_number_of_characters, on: :update

  def self.model_name
    Question.model_name
  end

  private

  def validate_maximum_and_minimum_number_of_characters
    minimum_number_of_characters = constraint_questions.find { |cq| cq.constraint.name == 'minimum_number_of_characters' }.value.to_i
    maximum_number_of_characters = constraint_questions.find { |cq| cq.constraint.name == 'maximum_number_of_characters' }.value.to_i

    errors.add(:base, 'Number of characters must be zero or positive.') if [maximum_number_of_characters, minimum_number_of_characters].any?(&:negative?)
    errors.add(:base, 'Maximum number of characters must be less than the minimum.') unless maximum_number_of_characters > minimum_number_of_characters
  end
end
