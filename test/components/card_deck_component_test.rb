# frozen_string_literal: true

require "test_helper"

class CardDeckComponentTest < ViewComponent::TestCase
  def test_defaults_to_masonry_controller_and_renders_cards
    render_inline(CardDeckComponent.new(id: "deck", reflex_root: true)) do |deck|
      card = deck.with_card
      card.with_header { "Card header" }
      card.with_body { "Card body" }
    end

    assert_selector "#deck.card-deck[data-controller='masonry'][data-reflex-root='#deck']"
    assert_selector ".card-header", text: "Card header"
    assert_selector ".card-body", text: "Card body"
  end

  def test_does_not_add_masonry_controller_when_disabled
    render_inline(CardDeckComponent.new(id: "deck-no-masonry", disable_masonry: true))

    assert_selector "#deck-no-masonry.card-deck"
    assert_no_selector "#deck-no-masonry[data-controller]"
  end

  def test_keeps_custom_controller_when_provided
    render_inline(CardDeckComponent.new(id: "deck-custom", data: { controller: "custom-grid" }))

    assert_selector "#deck-custom[data-controller='custom-grid']"
  end
end
