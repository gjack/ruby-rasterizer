require_relative "transformable"

class Instance
  include Transformable

  attr_reader :model, :position, :orientation_angle, :scale

  def initialize(model:, position: [0, 0, 0], orientation_angle: nil, scale: 1.0)
    @model = model
    @position = position
    @orientation_angle = orientation_angle
    @scale = scale
  end

  def transformations
    multiply_44matrices(translation_matrix(position), multiply_44matrices(rotation_matrix(orientation_angle), scale_matrix(scale)))
  end
end