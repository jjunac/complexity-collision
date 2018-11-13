require_relative 'segment'
class Board

    attr_reader :segments, :lines, :window_size, :radius

    def initialize(segment_length, nb_segments, display = true, window_size = 700, radial_speed_divider = 130, speed_divider = 200)
        @window_size = window_size
        @radial_speed_divider = radial_speed_divider
        @speed_divider = speed_divider
        @radius = segment_length
        @display = display
        @segments = Array.new(nb_segments) do
            Segment.new(
                rand + 0.05,
                rand + 0.05,
                rand * 2 - 1,
                rand * 2 - 1,
                rand * 2 * Math::PI,
                rand * 2 * Math::PI,
                segment_length
            )
        end
        if display
            @lines = Array.new(nb_segments) {Line.new(width: window_size / 400, color: 'white', z: 8)}
        else
            @lines = Array.new(nb_segments) {FakeLines.new}
        end
    end

    def update_physics(segment)
        segment.angle += (segment.radial_speed / @radial_speed_divider) % 2
        segment.x += segment.vx / @speed_divider
        unless 0 <= segment.x and segment.x <= 1
            segment.vx = -segment.vx
        end
        segment.y += segment.vy / @speed_divider
        unless 0 <= segment.y and segment.y <= 1
            segment.vy = -segment.vy
        end
    end

    def add_collision(collide, collisions)
        if @display
            collisions << Circle.new(x: collide[0], y: collide[1], radius: CIRCLE_RADIUS, color: "red", z: 9)
        else
            collisions << collide
        end
    end

    def update_positions
        @segments.length.times do |k|
            segment = @segments[k]
            # Update coordinates
            update_physics(segment)
            # Display
            dx = @radius * Math.cos(segment.angle)
            dy = @radius * Math.sin(segment.angle)
            px = segment.x * @window_size
            py = segment.y * @window_size
            @lines[k].x1 = px - dx
            @lines[k].y1 = py - dy
            @lines[k].x2 = px + dx
            @lines[k].y2 = py + dy
        end
    end

    def collide?(abx, aby, first_line, second_line)
        acx = second_line.x1 - first_line.x1
        acy = second_line.y1 - first_line.y1
        adx = second_line.x2 - first_line.x1
        ady = second_line.y2 - first_line.y1

        alpha = abx * acy - aby * acx
        beta = abx * ady - aby * adx

        if alpha < 0 == beta < 0
            return nil
        end

        cdx = second_line.x1 - second_line.x2
        cdy = second_line.y1 - second_line.y2
        cax = second_line.x1 - first_line.x1
        cay = second_line.y1 - first_line.y1
        cbx = second_line.x1 - first_line.x2
        cby = second_line.y1 - first_line.y2

        alpha = cdx * cay - cdy * cax
        beta = cdx * cby - cdy * cbx

        if alpha < 0 == beta < 0
            return nil
        end

        denominator = alpha - beta

        collision_x = (alpha * first_line.x2 - beta * first_line.x1) / denominator
        collision_y = (alpha * first_line.y2 - beta * first_line.y1) / denominator

        [collision_x, collision_y]
    end

end

class FakeLines

    attr_accessor :y1, :x1, :y2, :x2

    def initialize(x1 = 0, x2 = 0, y1 = 0, y2 = 0)
        @x1 = x1
        @x2 = x2
        @y1 = y1
        @y2 = y2
    end
end