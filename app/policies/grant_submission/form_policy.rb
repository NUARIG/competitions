# frozen_string_literal: true

module GrantSubmssion
  class FormPolicy < GrantPolicy

    def new?
      organization_admin_access? || grant_editor_access?
    end

    def update?
      new?
    end

    def edit?
      new?
    end

    private

      def form
        record
      end

      def grant
        clean_record_from_collection.grant
      end

      # def confirm_organization
      #   user.present? &&
      #     clean_record_from_collection.grant.organization == user.organization
      # end
    end
  end
end
