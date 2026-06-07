module ApplicationHelper
  def title(value)
    content_for(:title) { value }
  end
end
