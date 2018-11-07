require 'ruby2d'

require_relative 'lib/field'

WINDOW_SIZE = 700

set title: "Hello Triangle", width: WINDOW_SIZE, height: WINDOW_SIZE

N = 500

RADIUS = 800 / (Math.sqrt(N))
entities = []
field = Field.new(N)


update do
    entities.each {|e| e.remove}
    entities.clear

    for segment in field
        # Update coordinates
        segment.angle += (segment.radial_speed / 42) % 2
        segment.x += segment.vx / 200
        unless 0 <= segment.x and segment.x <= 1
            segment.vx = -segment.vx
        end
        segment.y += segment.vy / 200
        unless 0 <= segment.y and segment.y <= 1
            segment.vy = -segment.vy
        end
        # Display
        dx = RADIUS * Math.cos(segment.angle * Math::PI)
        dy = RADIUS * Math.sin(segment.angle * Math::PI)
        entities << Line.new(
                x1: segment.x * WINDOW_SIZE - dx, y1: segment.y * WINDOW_SIZE - dy,
                x2: segment.x * WINDOW_SIZE + dx, y2: segment.y * WINDOW_SIZE + dy,
                width: WINDOW_SIZE / 400,
                color: 'white',
                z: 1
        )
    end
end

show
