module WaitForTurbo
  def wait_for_turbo(timeout = nil)
    if has_css?('.turbo-progress-bar', visible: true, wait: (0.25).seconds)
      has_no_css?('.turbo-progress-bar', wait: timeout.presence || 2.seconds)
    end
  end

  def wait_for_turbo_frame(selector = 'turbo-frame', timeout = nil)
    if has_selector?("#{selector}[busy]", visible: true, wait: (0.25).seconds)
      has_no_selector?("#{selector}[busy]", wait: timeout.presence || 2.seconds)
    end
  end
end
