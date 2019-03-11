# frozen_string_literal: true

class StringQuestion < Question
  validate :validate_maximum_and_minimum_lengths

  def self.model_name
    Question.model_name
  end

  private

  def validate_maximum_and_minimum_lengths
    minimum_length = constraint_questions.find { |cq| cq.constraint.name == 'minimum_length' }.value.to_i
    maximum_length = constraint_questions.find { |cq| cq.constraint.name == 'maximum_length' }.value.to_i
    lengths = [maximum_length, minimum_length]

    errors.add(:base, 'Lengths must be zero or positive.')             if lengths.any? { |l| l < 0 }
    errors.add(:base, 'Lengths must be less than 255 characters.')     if lengths.any? { |l| l > 255 }
    errors.add(:base, 'Maximum length must be less than the minimum.') unless maximum_length > minimum_length
  end
end
