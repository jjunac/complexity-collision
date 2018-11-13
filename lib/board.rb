class Board

    def initialize(segment_radius, window_size = 700, radial_speed_divider = 130, speed_divider = 200)
        @window_size = window_size
        @radial_speed_divider = radial_speed_divider
        @speed_divider = speed_divider
        @radius = segment_radius
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

    def update_positions(field, lines)
        field.length.times do |k|
            segment = field[k]
            # Update coordinates
            update_physics(segment)
            # Display
            dx = @radius * Math.cos(segment.angle)
            dy = @radius * Math.sin(segment.angle)
            px = segment.x * @window_size
            py = segment.y * @window_size
            lines[k].x1 = px - dx
            lines[k].y1 = py - dy
            lines[k].x2 = px + dx
            lines[k].y2 = py + dy
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