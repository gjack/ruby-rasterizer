require_relative "canvas"

class Rasterizer

  attr_reader :canvas

  def initialize
    @canvas ||= Canvas.new
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

    canvas.save_image(filename: "example1.bmp")
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
end