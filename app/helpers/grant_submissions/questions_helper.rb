module GrantSubmissions::QuestionsHelper
  def get_question_id(question)
    question.id || 0
  end
end
