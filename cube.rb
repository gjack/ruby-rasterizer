require_relative "triangle"

class Cube
  attr_accessor :vertices, :triangles, :center, :bounds_radius

  # center and bounds_radius are used to describe the smallest sphere that can contain the cube
  # the radius comes from taking the distance from the center to the furthest vertex in the cube
  # which for our default cube would be at (1, 1, 1)
  def initialize(vertices: nil, triangles: nil, center: [0, 0, 0], bounds_radius: Math.sqrt(3))
    @center = center
    @vertices = vertices || default_vertices
    @triangles = triangles || default_triangles
    @bounds_radius = bounds_radius
  end

  def default_triangles
    [
      Triangle.new(vertices: [0, 1, 2], color: [255, 0, 0]),
      Triangle.new(vertices: [0, 2, 3], color: [255, 0, 0]),
      Triangle.new(vertices: [4, 0, 3], color: [0, 255, 0]),
      Triangle.new(vertices: [4, 3, 7], color: [0, 255, 0]),
      Triangle.new(vertices: [5, 4, 7], color: [0, 0, 255]),
      Triangle.new(vertices: [5, 7, 6], color: [0, 0, 255]),
      Triangle.new(vertices: [1, 5, 6], color: [255, 255, 0]),
      Triangle.new(vertices: [1, 6, 2], color: [255, 255, 0]),
      Triangle.new(vertices: [4, 5, 1], color: [255, 0, 255]),
      Triangle.new(vertices: [4, 1, 0], color: [255, 0, 255]),
      Triangle.new(vertices: [2, 6, 7], color: [0, 255, 255]),
      Triangle.new(vertices: [2, 7, 3], color: [0, 255, 255]),
    ]
  end

  def default_vertices
    [[1, 1, 1], [-1, 1, 1], [-1, -1, 1], [1, -1, 1], [1, 1, -1], [-1, 1, -1], [-1, -1, -1], [1, -1, -1]]
  end
end