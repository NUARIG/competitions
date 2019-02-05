module ApplicationHelper
  # Returns the full title on a per-page basis.
  def title_tag_content(page_title: '')
    base_title = "Competitions"
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end
end
