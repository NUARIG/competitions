module GrantSubmissions::ResponsesHelper
  def allowed_file_extensions
    GrantSubmission::Response::ALLOWED_DOCUMENT_FILE_EXTENSIONS.join(',')
  end
end
