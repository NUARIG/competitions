class GrantUserPolicy < AccessPolicy
	def index?
    user.id.in?(grant_read_users.pluck(:user_id))
  end

  def show?
  	index?
  end

  def create?
  	user.id.in?(grant_write_users.pluck(:user_id))
  end

  def new?
    create?
  end

  def update?
  	create? 
  end

  def edit?
    create?
  end

  def destroy?
  	user.id.in?(grant_destroy_users.pluck(:user_id))
  end

	private
		# def grant
  #     clean_record = record.try(:first) ? record.first : record
		# 	clean_record.grant
		# end

    def grant_users
      record
    end

    def grant_read_users
      GrantUser.where(grant_role: (%w[admin editor viewer]))
    end

    def grant_write_users
      GrantUser.where(grant_role: (%w[admin editor]))
    end

    def grant_destroy_users
      GrantUser.where(grant_role: (%w[admin]))
    end

end