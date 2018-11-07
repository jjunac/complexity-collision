require 'ruby2d'

require_relative 'lib/field'

WINDOW_SIZE = 700

set title: "Hello Triangle", width: WINDOW_SIZE, height: WINDOW_SIZE

N = 300

RADIUS = 800 / Math.sqrt(N)

SPEED_DIVIDER = 200
RADIAL_SPEED_DIVIDER = 42

entities = []
field = Field.new(N)


update do
    entities.each {|e| e.remove}
    entities.clear

    lines = []
    # Movement and display
    field.each do |segment|
        # Update coordinates
        segment.angle += (segment.radial_speed / RADIAL_SPEED_DIVIDER) % 2
        segment.x += segment.vx / SPEED_DIVIDER
        unless 0 <= segment.x and segment.x <= 1
            segment.vx = -segment.vx
        end
        segment.y += segment.vy / SPEED_DIVIDER
        unless 0 <= segment.y and segment.y <= 1
            segment.vy = -segment.vy
        end
        # Display
        dx = RADIUS * Math.cos(segment.angle * Math::PI)
        dy = RADIUS * Math.sin(segment.angle * Math::PI)
        line = Line.new(
                x1: segment.x * WINDOW_SIZE - dx, y1: segment.y * WINDOW_SIZE - dy,
                x2: segment.x * WINDOW_SIZE + dx, y2: segment.y * WINDOW_SIZE + dy,
                width: WINDOW_SIZE / 400,
                color: 'white',
        )
        lines << line
        entities << line
    end
    # Collision detection
    n_collision = 0
    (lines.length - 1).times do |i|
        abx = lines[i].x2 - lines[i].x1
        aby = lines[i].y2 - lines[i].y1
        (i+1...lines.length).each do |j|
            acx = lines[j].x1 - lines[i].x1
            acy = lines[j].y1 - lines[i].y1
            adx = lines[j].x2 - lines[i].x1
            ady = lines[j].y2 - lines[i].y1

            alpha = abx * acy - aby * acx
            beta = abx * ady - aby * adx

            if (alpha == 0 or beta == 0) or not ((alpha < 0 and beta > 0) or (alpha > 0 and beta < 0))
                next
            end

            cdx = lines[j].x1 - lines[j].x2
            cdy = lines[j].y1 - lines[j].y2
            cax = lines[j].x1 - lines[i].x1
            cay = lines[j].y1 - lines[i].y1
            cbx = lines[j].x1 - lines[i].x2
            cby = lines[j].y1 - lines[i].y2

            alpha = cdx * cay - cdy * cax
            beta = cdx * cby - cdy * cbx

            if alpha < 0 == beta < 0
                next
            end

            denominator = alpha - beta

            collisionx = (alpha * lines[i].x2 - beta * lines[i].x1) / denominator
            collisiony = (alpha * lines[i].y2 - beta * lines[i].y1) / denominator

            entities << Circle.new(x: collisionx, y: collisiony, radius: WINDOW_SIZE / 200, color: 'red')
        end
    end
end

show
