module ApplicationHelper
  # Returns the full title on a per-page basis.
  def title_tag_content(page_title: '')
    base_title = "Competitions"
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def date_mmddYYYY(date)
    byebug
    date.nil? ? '' : date.strftime('%m/%d/%Y')
  end
end
