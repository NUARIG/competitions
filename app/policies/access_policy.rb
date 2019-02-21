class AccessPolicy < ApplicationPolicy
	private
		# Policies for new
		def can_create?
			user.organization_role.in?(%w[admin editor])
		end

		def can_view?
			user.organization_role.in?(%w[admin editor viewer])
		end

		# Organization access
		def organization_admin_access?
			confirm_organization && 
			user.organization_role == 'admin'
		end

		def organization_editor_access?
			confirm_organization && 
			can_create?
		end

		def organization_viewer_access?
			confirm_organization && 
			can_view?
		end

		def organization_basic_access?
			user.present? 
		end


		def confirm_organization
			user.present? && 
			clean_record_from_collection.organization == user.organization 
		end

		def clean_record_from_collection
			clean_record = record.try(:first) ? record.first : record
		end

end