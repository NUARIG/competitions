module DeviseHelper
  def devise_error_messages!
    flash.now[:error] = resource.errors.full_messages if resource.errors.full_messages.any?
    return ''
  end
end
