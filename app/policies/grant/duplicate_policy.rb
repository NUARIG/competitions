# frozen_string_literal: true
module Grant
  class DuplicatePolicy < GrantPolicy
  # TODO: Should there be a GrantObjectPolicy
  # TODO: look at it authorizing on the one grant Does it need any of the private methods?

    def create?
      organization_admin_access? || grant_editor_access?
    end

    def new?
      create?
    end

    private

      def duplicate
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
