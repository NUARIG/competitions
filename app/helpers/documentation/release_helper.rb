module Documentation::ReleaseHelper
  def github_issue_link(issue: issue)
    link_to "##{issue}", "https://github.com/NUARIG/competitions/issues/#{issue}"
  end
end