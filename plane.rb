
# This class represents a 3D plane
# by the general equation Ax + By + Cz + D = 0
# or rewriten with vectors 
# <N, P> + D = 0
# where N is a unitary vector normal to the plane, P is a point on the plane
# and -D is the signed distance from the origin to the plane
class Plane
  attr_reader :normal, :distance

  def initialize(normal:, distance:)
    @normal = normal
    @distance = distance
  end
end
