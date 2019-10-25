# frozen_string_literal: true

class BannerPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.system_admin?
        scope.all
      end
    end
  end

  def new?
    user.system_admin?
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def show?
    new?
  end

  def update?
    new?
  end

  def destroy?
    new?
  end

  private

  def banner
    record
  end
end
