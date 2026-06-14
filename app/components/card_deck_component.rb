class CardDeckComponent < ViewComponent::Base
  renders_many :cards, CardComponent
  renders_one :body

  def initialize(reflex_root: false, id: nil, data: {}, disable_masonry: false, klass: "")
    @reflex_root = reflex_root
    @id = id
    @data = data
    @klass = klass

    if !disable_masonry
      @data[:controller] ||= "masonry"
    end
  end
end
