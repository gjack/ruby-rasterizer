class Instance
  attr_reader :model, :position

  def initialize(model:, position:)
    @model = model
    @position = position
  end

  def translate_to_position
    model.vertices.map do |vertex|
      [vertex[0] + position[0], vertex[1] + position[1], vertex[2] + position[2]]
    end
  end
end