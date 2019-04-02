module GrantServices
  module SoftDelete
    def self.call(grant:)
      begin
        if grant.soft_delete!
          OpenStruct.new(success?: true, message: 'Successful soft delete.')
        else
          OpenStruct.new(success?: false, message: 'Grant could not be deleted.')
        end
      rescue Exception => e
        OpenStruct.new(success?: false, message: e.message)
      end
    end
  end
end
