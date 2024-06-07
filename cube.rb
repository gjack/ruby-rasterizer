require_relative "triangle"

class Cube
  attr_accessor :vertices, :triangles, :position
  attr_reader :center

  def initialize(vertices: [], triangles: [], position: [0, 0, 0])
    @center = [0, 0, 0]
    @vertices = vertices
    @triangles = triangles
    @position = position
  end

  def triangles
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

  def translate_to_position
    @vertices.map do |vertex|
      [vertex[0] + position[0], vertex[1] + position[1], vertex[2] + position[2]]
    end
  end
end