# frozen_string_literal: true

module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :not_deleted, -> { where(deleted_at: nil) }
    scope :deleted,     -> { where.not(deleted_at: nil) }
  end

  def process_soft_delete
    update_column :deleted_at, Time.now
  end

  def soft_delete!
    begin
      self.transaction do
        if is_soft_deletable?
          process_soft_delete
          process_association_soft_delete if self.respond_to?(:process_association_soft_delete)
        end
      end
    rescue Exception => e
      raise e.message
    end
  end

  def deleted?
    deleted_at.present?
  end

  # def is_soft_deletable?
  #   raise NotImplementedError, 'class did not define is_soft_deletable?'
  # end
end
