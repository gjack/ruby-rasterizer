require_relative "canvas"
require_relative "viewport"
require_relative "camera"
require_relative "cube"
require_relative "instance"
require_relative "transformable"

class Rasterizer
  include Transformable
  
  attr_reader :canvas, :viewport, :camera, :scene

  def initialize
    @canvas ||= Canvas.new
    @viewport ||= Viewport.new
    @camera ||= Camera.new
  end

  def draw_line(point1, point2, color)
    if (point2[0] - point1[0]).abs > (point2[1] - point1[1]).abs 
      # line is horizontalish
      if point1[0] > point2[0]
        point2, point1 = point1, point2
      end

      y_values = interpolate(point1[0], point1[1], point2[0], point2[1])

      (point1[0]..point2[0]).each do |x|
        canvas.put_pixel(x, y_values[x - point1[0]], color)
      end
    else
      # line is verticalish
      if point1[1] > point2[1]
        point2, point1 = point1, point2
      end
      
      x_values = interpolate(point1[1], point1[0], point2[1], point2[0])

      (point1[1]..point2[1]).each do |y|
        canvas.put_pixel(x_values[y - point1[1]], y, color)
      end
    end
  end

  # we know the slope and we know all points in a line
  # follow the equation y(x + 1) = y(x) + a 
  # where a is the slope
  def interpolate(i0, d0, i1, d1)
    # edge case for completely vertical or horizontal lines
    if i0 == i1
      return [d0]
    end

    values = []

    a = (d1 - d0) / (i1 - i0).to_f
    d = d0
    # for every integer independent value
    # interpolate the dependent value using the previous one
    # and the slope
    (i0..i1).each do
      values << d
      d = d + a
    end
    values
  end

  def draw_wireframe_triangle(point0, point1, point2, color)
    draw_line(point0, point1, color)
    draw_line(point1, point2, color)
    draw_line(point2, point0, color)
  end

  def draw_filled_triangle(point0, point1, point2, color)
    # sort the points so that point0 < point1 < point2
    if point1[1] < point0[1]
      point0, point1 = point1, point0
    end
    if point2[1] < point0[1]
      point0, point2 = point2, point0
    end
    if point2[1] < point1[1]
      point1, point2 = point2, point1
    end

    # compute the x coordinates of the triangle edges
    # also compute intensity h assuming each point can have a third element
    # which signifies intensity ranging from 0.0 (black) to 1.0 (the color)
    x01 = interpolate(point0[1], point0[0], point1[1], point1[0]).map(&:floor)
    h01 = interpolate(point0[1], point0[2] || 1.0, point1[1], point1[2] || 1.0)

    x12 = interpolate(point1[1], point1[0], point2[1], point2[0]).map(&:floor)
    h12 = interpolate(point1[1], point1[2] || 1.0, point2[1], point2[2] || 1.0)

    x02 = interpolate(point0[1], point0[0], point2[1], point2[0]).map(&:floor)
    h02 = interpolate(point0[1], point0[2] || 1.0, point2[1], point2[2] || 1.0)

    # concatenate the short sides
    x01.pop
    x012 = x01 + x12

    h01.pop
    h012 = h01 + h12

    # determine which is left and which is right
    m = (x012.length / 2.0).floor

    if x02[m] < x012[m]
      x_left = x02
      h_left = h02

      x_right = x012
      h_right = h012
    else
      x_left = x012
      h_left = h012

      x_right = x02
      h_right = h02
    end

    # draw the horizontal segments asigning each a color shade modified by 
    # the calculated intensity for each pixel 
    (point0[1]..point2[1]).each do |y|
      x_l = x_left[y - point0[1]]
      x_r = x_right[y - point0[1]]
      
      # calculate the intensity for each pixel along the horizontal line at this y
      h_segment = interpolate(x_l, h_left[y - point0[1]], x_r, h_right[y - point0[1]])

      (x_l..x_r).each do |x|
        shaded_color = color.map {|code| code * h_segment[x - x_l] }
        canvas.put_pixel(x, y, shaded_color)
      end
    end
  end

  def viewport_to_canvas_coordinates(x, y)
    # these are used in draw_line and we need integers, not floats
    [x * canvas.width / viewport.width.to_f, y * canvas.height / viewport.height.to_f].map(&:floor)
  end

  def projected_vertex(v)
    viewport_to_canvas_coordinates(v[0] * camera.distance / v[2], v[1] * camera.distance / v[2])
  end

  def render_triangle(triangle, projected)
    draw_wireframe_triangle(projected[triangle.vertices[0]], projected[triangle.vertices[1]], projected[triangle.vertices[2]], triangle.color)
  end

  def render_instance(instance)
    model = instance.model
    translated = instance.translate_to_position
    projected = translated.map do |vertex|
      projected_vertex(vertex)
    end

    model.triangles.each do |triangle|
      render_triangle(triangle, projected)
    end
  end

  def render_scene
    scene[:instances].each do |instance|
      render_instance(instance)
    end

    canvas.save_image(filename: "scene_of_cubes.bmp")
  end

  def scene
    @scene ||= {
      instances: [
        Instance.new(
          model: Cube.new(vertices: [[1, 1, 1], [-1, 1, 1], [-1, -1, 1], [1, -1, 1], [1, 1, -1], [-1, 1, -1], [-1, -1, -1], [1, -1, -1]], position: [-1.5, 0, 7]),
          position: [-1.5, 0, 7]
        ),
        Instance.new(
          model: Cube.new(vertices: [[1, 1, 1], [-1, 1, 1], [-1, -1, 1], [1, -1, 1], [1, 1, -1], [-1, 1, -1], [-1, -1, -1], [1, -1, -1]], position: [1.5, 0, 7]),
          position: [1.5, 0, 7]
        ),
      ]
    }
  end
end

