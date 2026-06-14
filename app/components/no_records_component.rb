class NoRecordsComponent < ViewComponent::Base
  def initialize(render: true)
        @render = render
  end

  def render?
    @render
  end
end
