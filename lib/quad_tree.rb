class BoundingBox

  attr_accessor :center, :half_range

  def initialize(center, half_range)
    @center = center
    @half_range = half_range
  end

  def contains_point(point)
    if @center[0] - @half_range <= point[0] <= @center[0] + @half_range
      if @center[1] - @half_range <= point[1] <= @center[1] + @half_range
        return true
      end
    end
    false
  end

  def intersects_box(box)
    if @center[0] - box.center[0] < @range + box.half_range or @center[0] - box.center[0] < @range + box.half_range
      return true
    end
    false
  end

end


class QuadTree
  MAX_CAPACITY = 4

  def initialize(boundary)
    @boundary = boundary
    @points = []
    @north_west = nil
    @north_east = nil
    @south_west = nil
    @south_east = nil
  end

  def subdivide()
    new_range = @boundary.half_range / 2
    @north_west = QuadTree.new(BoundingBox.new([@boundary.center[0] - new_range, @boundary.center[1] - new_range], new_range))
    @north_east = QuadTree.new(BoundingBox.new([@boundary.center[0] + new_range, @boundary.center[1] - new_range], new_range))
    @south_west = QuadTree.new(BoundingBox.new([@boundary.center[0] - new_range, @boundary.center[1] + new_range], new_range))
    @south_east = QuadTree.new(BoundingBox.new([@boundary.center[0] + new_range, @boundary.center[1] + new_range], new_range))
  end

  def insert(point)
    unless @boundary.contains_point
      return false
    end

    if @points.length < MAX_CAPACITY
      @points << point
    end

    if @north_west == nil
      subdivide
    end

    if @north_west.insert(point)
      return true
    end
    if @north_east.insert(point)
      return true
    end
    if @south_west.insert(point)
      return true
    end
    if @south_east.insert(point)
      return true
    end
  end

  def query_range(range)
    res = []
    unless @boundary.intersects_box(range)
      return res
    end

    for point in @points
      if range.contains_point(point)
        res << point
      end
    end
    if @north_west.nil?
      return res
    end
    res += @north_west.query_range(range)
    res += @north_east.query_range(range)
    res += @south_east.query_range(range)
    res += @south_east.query_range(range)
    res
  end

  def delete(point)
    unless @boundary.contains_point
      return false
    end

    if @north_west.nil?
      @points.delete(point)
    end

    if @north_west.delete(point)
      return true
    end
    if @north_east.delete(point)
      return true
    end
    if @south_west.delete(point)
      return true
    end
    if @south_east.delete(point)
      return true
    end
  end
end