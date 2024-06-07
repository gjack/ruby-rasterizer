class Triangle
  attr_accessor :vertices, :color

  def initialize(vertices: [], color: [0, 0, 0])
    @vertices = vertices
    @color = color
  end
end
