class CardComponent < ViewComponent::Base
  renders_one :header
  renders_one :body
  renders_one :header_actions
  renders_one :header_secondary
  renders_one :footer

  def initialize(klass: "col-12", tabs: nil, data: {}, render: true, formats: [], empty: false, id: nil, footer_class: nil)
    @klass = klass
    @tabs = tabs
    @data = data
    @render = render
    @formats = formats
    @empty = empty
    @id = id
    @footer_class = footer_class
  end

  attr_reader :footer_class

  def render?
    @render
  end
end
