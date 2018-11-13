class BoundingBox

    attr_accessor :center, :half_range

    def initialize(center, half_range)
        @center = center
        @half_range = half_range
    end

    def contains_point(point)
        if @center[0] - @half_range <= point[0] && point[0] <= @center[0] + @half_range
            if @center[1] - @half_range <= point[1] && point[1] <= @center[1] + @half_range
                return true
            end
        end
        false
    end

    def intersects_box(box)
        if @center[0] - box.center[0] < @range + box.half_range or @center[1] - box.center[1] < @range + box.half_range
            return true
        end
        false
    end

end


class QuadTree
    attr_reader :north_west, :north_east, :lines, :south_east, :boundary, :south_west

    MAX_CAPACITY = 32
    MIN_SIZE = 100

    def initialize(boundary)
        @boundary = boundary
        @lines = []
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

    def insert_line(line)
        points = [[line.x1, line.y1], [(line.x1 + line.x2) / 2.0, (line.y1 + line.y2) / 2.0], [line.x2, line.y2]]
        points.each do |point|
            insert(point, line)
        end
    end

    def insert(point, line)
        unless @boundary.contains_point(point)
            return false
        end

        if @boundary.half_range <= MIN_SIZE || @lines.length < MAX_CAPACITY
            @lines << line
            return true
        end

        if @north_west == nil
            subdivide
        end

        if @north_west.insert(point, line)
            return true
        end
        if @north_east.insert(point, line)
            return true
        end
        if @south_west.insert(point, line)
            return true
        end
        if @south_east.insert(point, line)
            return true
        end
    end

    def query_range(line)
        points = [[line.x1, line.y1], [line.x2, line.y2], [(line.x1 + line.x2) / 2.0, (line.y1 + line.y2) / 2.0]]
        res = []
        points.each do |point|
            res += query_points(point)
        end
        res
    end

    def query_points(point)
        unless @boundary.contains_point(point)
            return []
        end

        res = [] + @lines.select do |l|
            !((l.x1 == point[0] && l.y1 == point[1]) || (l.x2 == point[0] && l.y2 == point[1]) || ((l.x1 + l.x2) / 2 == point[0] && (l.y1 + l.y2) / 2 == point[1]))
        end
        if @north_west.nil?
            return res
        end
        res += @north_west.query_points(point)
        res += @north_east.query_points(point)
        res += @south_east.query_points(point)
        res += @south_east.query_points(point)
        return res
    end

end