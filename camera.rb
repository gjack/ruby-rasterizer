require_relative "transformable"

class Camera
  include Transformable
  attr_reader :origin, :distance, :orientation_angle
  
  # initialize with origin and distance to projection plane
  def initialize(origin: [0,0,0], distance: 1.0, orientation_angle: nil)
    @origin = origin
    @distance = distance
    @orientation_angle = orientation_angle
  end

  def transformations
    multiply_44matrices(transposed_matrix(rotation_matrix(orientation_angle)), translation_matrix(multiply_by_scalar(origin, -1)))
  end
end