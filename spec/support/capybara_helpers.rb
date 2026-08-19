RSpec.configure do |config|
  def authorization_error_text
     I18n.t('pundit.default')
  end

  def fill_in_trix_editor(id, with:)
    find(:xpath, "//trix-editor[@input='#{id}']", visible: true, wait: 3).click.set(with)
  end

  def find_trix_editor(id)
    find(:xpath, "//*[@id='#{id}']", visible: false)
  end
end
