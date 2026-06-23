# frozen_string_literal: true

require "test_helper"

class NoRecordsComponentTest < ViewComponent::TestCase
  def test_renders_no_records_container
    render_inline(NoRecordsComponent.new)

    assert_selector ".no-records"
  end

  def test_does_not_render_when_disabled
    render_inline(NoRecordsComponent.new(render: false))

    assert_no_selector ".no-records"
  end
end
