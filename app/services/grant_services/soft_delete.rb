module GrantServices
  module SoftDelete
    def self.call(grant:)
      begin
        grant.soft_delete!
        OpenStruct.new(success?: true, message: 'Successful soft delete.')
      rescue Exception => e
        OpenStruct.new(success?: false, message: e.message)
      end
    end
  end
end
