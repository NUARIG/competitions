# frozen_string_literal: true
module Grant
  class DuplicatePolicy < GrantPolicy
  # TODO: Should there be a GrantObjectPolicy

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
