require_relative "transformable"
require_relative "plane"

class Camera
  include Transformable
  attr_reader :origin, :distance, :orientation_angle, :clipping_planes
  
  # initialize with origin and distance to projection plane
  def initialize(origin: [0,0,0], distance: 1.0, orientation_angle: nil, clipping_planes: nil)
    @origin = origin
    @distance = distance
    @orientation_angle = orientation_angle
    @clipping_planes = clipping_planes || default_planes
  end

  def transformations
    multiply_44matrices(transposed_matrix(rotation_matrix(orientation_angle)), translation_matrix(multiply_by_scalar(origin, -1)))
  end

  # assuming a FOV of 90 degrees
  # these planes enclose the visible volume for our camera
  # anything outside of this volume will be clipped
  def default_planes
    l2 = 1.0 / Math.sqrt(2)

    [
      Plane.new(normal: [0, 0, 1], distance: -1),  # projection plane
      Plane.new(normal: [l2, 0, l2], distance: 0), # left
      Plane.new(normal: [-l2, 0, l2], distance: 0), #rigth
      Plane.new(normal: [0, -l2, l2], distance: 0), #top
      Plane.new(normal: [0, l2, l2], distance: 0), # bottom
    ]
  end
end