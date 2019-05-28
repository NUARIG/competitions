# frozen_string_literal: true
module Grant
  class StatePolicy < GrantPolicy
    # TODO: Should there be a GrantObjectPolicy

    def update?
      organization_admin_access? || grant_editor_access?
    end

    private

      def state
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
