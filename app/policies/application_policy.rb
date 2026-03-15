# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    belongs_to_user?
  end

  def create?
    belongs_to_user?
  end

  def new?
    create?
  end

  def update?
    belongs_to_user?
  end

  def edit?
    update?
  end

  def delete?
    belongs_to_user?
  end

  def destroy?
    belongs_to_user?
  end

  private
  def belongs_to_user?
    record.user == user
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(user_id: user.id)
    end

    private

    attr_reader :user, :scope
  end
end
