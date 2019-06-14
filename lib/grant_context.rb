class GrantContext
  attr_reader :user, :grant

  def initialize(user, grant)
    @user = user
    @grant = grant
  end
end