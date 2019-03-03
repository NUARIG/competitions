class IntegerQuestion < Question
  validate :valid_maximum_and_minimum_values

  def self.model_name
    Question.model_name
  end

  private
    def valid_maximum_and_minimum_values
      minimum_value = self.constraint_questions.find { |cq| cq.constraint.name == 'minimum_value' }.value.to_i
      maximum_value = self.constraint_questions.find { |cq| cq.constraint.name == 'maximum_value' }.value.to_i

      errors.add(:base, 'Maximum value must be less than the minimum.') unless maximum_value > minimum_value
    end
end
