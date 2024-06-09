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

  def clip_triangle(triangle, vertices, plane, clipped_triangles)
    v0 = vertices[triangle.vertices[0]]
    v1 = vertices[triangle.vertices[1]]
    v2 = vertices[triangle.vertices[2]]

    d0 = dot_product_vectors(plane.normal, v0) + plane.distance
    d1 = dot_product_vectors(plane.normal, v1) + plane.distance
    d2 = dot_product_vectors(plane.normal, v2) + plane.distance

    # only dealing with the case where the triangle is completely in front of the clipping plane
    # if a triangle intersects the clipping plane we would need to replace it with one or two 
    # new triangles to cover the area of the triangle in front of the plane
    # this would change the triangles and the vertices
    # and return a new collection of triangles and vertices
    if d0 > 0 && d1 > 0 && d2 > 0
      clipped_triangles.push(triangle)
    end

    return clipped_triangles
  end

  # transform the vertices in the model and clip them against the planes
  def transform_and_clip(clipping_planes, model, scale, transform)
    ## attempt early discard of model inside the bounding sphere

    # express model.center in homogeneous coordinates
    sphere_center = multiply_4dvector_44matrix(model.center.push(1), transform)
    sphere_radius = model.bounds_radius * scale
    clipping_planes.each do |plane|
      # if the signed distance between the center of the sphere and the plane
      # is less than the sphere radius then the sphere is outside the viewable volume
      return nil if dot_product_vectors(plane.normal, sphere_center) < -sphere_radius
    end

    ## apply the transformation to all the vertices in the model
    new_vertices = model.vertices.map do |vertex|
      multiply_4dvector_44matrix(vertex.push(1), transform)
    end

    # clip the entire model against each successive plane
    clipped_triangles = model.triangles
    clipping_planes.each do |plane|
      new_clipped_triangles = []
      clipped_triangles.each do |triangle|
        new_clipped_triangles = clip_triangle(triangle, new_vertices, plane, new_clipped_triangles)
      end 
      clipped_triangles = new_clipped_triangles
    end

    return model.class.new(vertices: new_vertices, triangles: clipped_triangles, center: model.center, bounds_radius: model.bounds_radius)
  end

  def render_instance(model)
    projected = model.vertices.map do |vertex|
      # vertex in homogeneous coordinates (canonical)
      vertexh = vertex.push(1)

      projected_vertex(vertexh)
    end

    model.triangles.each do |triangle|
      render_triangle(triangle, projected)
    end
  end

  def render_scene
    camera_transformations = camera.transformations

    scene[:instances].each do |instance|
      transformations = multiply_44matrices(camera_transformations, instance.transformations)
      clipped = transform_and_clip(camera.clipping_planes, instance.model, instance.scale, transformations)
    
      render_instance(clipped) unless clipped.nil?
    end

    canvas.save_image(filename: "images/scene_of_cubes_clipped.bmp")
  end

  def camera
    @camera ||= scene[:camera]
  end

  def scene
    @scene ||= {
      camera: Camera.new(origin: [0, 0, 0], orientation_angle: nil),
      instances: [
        Instance.new(
          model: Cube.new,
          position: [-1.5, 0, 7],
          scale: 0.75
        ),
        Instance.new(
          model: Cube.new,
          position: [2.5, 1.25, 4.5],
        ),
      ]
    }
  end
end

