# frozen_string_literal: true

class BannerPolicy < ApplicationPolicy

  def index?
    user.system_admin?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def show?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end

  private

  def banner
    record
  end
end