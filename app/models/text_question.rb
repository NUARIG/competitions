# frozen_string_literal: true

class TextQuestion < Question
  validate :validate_maximum_and_minimum_lengths

  def self.model_name
    Question.model_name
  end

  private

  def validate_maximum_and_minimum_lengths
    minimum_length = constraint_questions.find { |cq| cq.constraint.name == 'minimum_length' }.value.to_i
    maximum_length = constraint_questions.find { |cq| cq.constraint.name == 'maximum_length' }.value.to_i

    errors.add(:base, 'Lengths must be zero or positive.') if [maximum_length, minimum_length].any?(&:negative?)
    errors.add(:base, 'Maximum length must be less than the minimum.') unless maximum_length > minimum_length
  end
end
