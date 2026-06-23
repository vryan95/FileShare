# frozen_string_literal: true

require "test_helper"

class CardComponentTest < ViewComponent::TestCase
  def test_renders_header_body_and_footer
    render_inline(CardComponent.new(klass: "col-6", id: "files-card", data: { controller: "demo" }, footer_class: "footer-extra")) do |card|
      card.with_header { "Files" }
      card.with_body { "Body content" }
      card.with_footer { "Footer content" }
    end

    assert_selector "#files-card.card-component.col-6[data-controller='demo']"
    assert_selector ".card-header", text: "Files"
    assert_selector ".card-body", text: "Body content"
    assert_selector ".card-footer.footer-extra", text: "Footer content"
  end

  def test_renders_tabs_when_tabs_are_provided
    tabs = [
      { id: "my_files_tab", text: "My files" },
      { id: "shared_files_tab", text: "Shared files" }
    ]

    render_inline(CardComponent.new(tabs:, id: "tabbed-card")) do |card|
      card.with_header { "Header" }
      card.with_body { "Tabbed content" }
    end

    assert_selector "#tabbed-card .card.card-tabs"
    assert_selector "a.nav-link.active[href='#my_files_tab']", text: "My files"
    assert_selector "a.nav-link[href='#shared_files_tab']", text: "Shared files"
  end

  def test_renders_no_records_component_when_empty
    render_inline(CardComponent.new(empty: true))

    assert_selector ".no-records"
  end
end
