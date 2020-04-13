class ServiceError::InputInvalid < StandardError
  def initialize(error:)
    @error = error
  end
end

