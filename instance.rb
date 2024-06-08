class Instance
  attr_reader :model, :position

  def initialize(model:, position:)
    @model = model
    @position = position
  end
end