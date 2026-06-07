module ApplicationHelper
  def title(value)
    content_for(:title) { value }
  end

  def icon(icon, options = {})
    file = File.read("node_modules/bootstrap-icons/icons/#{icon}.svg")
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css "svg"

    if options[:class].present?
      svg["class"] += " " + options[:class]
    end

    if icon.include?("file") && icon != "file-ruled"
      options[:style] ||= "margin-top: -5px"
    end

    if options[:style].present?
      svg["style"] = options[:style]
    end

    doc.to_html.html_safe
  end
end
