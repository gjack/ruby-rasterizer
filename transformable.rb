module Transformable

  IDENTITY_4MATRIX = [
    [1, 0, 0, 0],
    [0, 1, 0, 0], 
    [0, 0, 1, 0],
    [0, 0, 0, 1]
  ]

  def multiply_by_scalar(vect, scalar)
    vect.map do |coord|
      coord * scalar
    end
  end

  # multipliy a 4D vector by a 4 x 4 matrix
  def multiply_4dvector_44matrix(vect, matrix)
    (0..3).map do |i|
      (0..3).inject(0) do |sum, j|
        sum += vect[j] * matrix[i][j]
        sum
      end
    end
  end

  # multiply 2 4 X 4 matrices
  def multiply_44matrices(matrix1, matrix2)
    (0..3).map do |i|
      (0..3).map do |j|
        (0..3).inject(0) do |sum, k|
          sum += matrix1[i][k] * matrix2[k][j]
          sum
        end
      end
    end
  end

  # creates a homogeneous translation matrix
  def translation_matrix(translation)
    [
      [1, 0, 0, translation[0]],
      [0, 1, 0, translation[1]],
      [0, 0, 1, translation[2]],
      [0, 0, 0, 1]
    ]
  end

  # creates a homogeneous scale matrix
  def scale_matrix(scale)
    [
      [scale, 0, 0, 0],
      [0, scale, 0, 0],
      [0, 0, scale, 0],
      [0, 0, 0, 1]
    ]
  end

  # homogeneous rotation around the Y axis with respect to the origin
  # by an angle in degrees
  def rotation_matrix(angle)
    return IDENTITY_4MATRIX unless angle

    cos = Math.cos(angle * Math::PI / 180)
    sin = Math.sin(angle * Math::PI / 180)

    [
      [cos, 0, -sin, 0],
      [0, 1, 0, 0],
      [sin, 0, cos, 0],
      [0, 0, 0, 1]
    ]
  end

  # transpose a 4 X 4 matrix
  def transposed_matrix(matrix)
    (0..3).map do |i|
      (0..3).map do |j|
        matrix[j][i]
      end
    end
  end

  def dot_product_vectors(vect1, vect2)
    (0..2).inject(0) do |sum, coord|
      sum += vect1[coord] * vect2[coord]
      sum
    end
  end
end
