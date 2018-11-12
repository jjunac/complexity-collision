require 'ruby2d'

require_relative 'lib/field'

WINDOW_SIZE = 700

set title: "Hello Triangle", width: WINDOW_SIZE, height: WINDOW_SIZE

# Parameters
N = 200
SPEED_DIVIDER = 200
RADIAL_SPEED_DIVIDER = 130

# Constants for computation optimisation
RADIUS = 800 / Math.sqrt(N)
LINE_WIDTH = WINDOW_SIZE / 400
CIRCLE_RADIUS = WINDOW_SIZE / 200


"""collisions = Array.new(N) { Array.new(N) { nil } }
is_displayed = Array.new(N) { Array.new(N) { false } }
N.times do |i|
    (i+1...N).each do |j|
        collisions[i][j] = Circle.new(x: 0, y: 0, radius: CIRCLE_RADIUS, color: 'red')
        collisions[i][j].remove
    end
end"""

collisions = []

field = Field.new(N)
lines = Array.new(N) { Line.new(width: LINE_WIDTH, color: 'white') }

background = Rectangle.new(x: 0, y:0, width:80, height: 26, color:'silver', z: 10)
text_collisions = Text.new("", x: 2, y:2, size:10, color:'black', z: 11)
text_fps = Text.new("FPS: ", x: 2, y: 14, size:10, color:'black', z: 11)

last_fps = Time.now.to_f
frames = 0

update do
    now = Time.now.to_f
    if now > last_fps + 1
        text_fps.text = "FPS: #{frames}"
        frames = 0
        last_fps = now
    end
    # Movement and display
    field.length.times do |k|
        segment = field[k]
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
        dx = RADIUS * Math.cos(segment.angle)
        dy = RADIUS * Math.sin(segment.angle)
        px = segment.x * WINDOW_SIZE
        py = segment.y * WINDOW_SIZE
        lines[k].x1 = px - dx
        lines[k].y1 = py - dy
        lines[k].x2 = px + dx
        lines[k].y2 = py + dy
    end
    # Collision detection
    n_collisions = 0
    collisions.each(&:remove)
    collisions = []
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

            if alpha < 0 == beta < 0
                """collisions[i][j].remove
                if is_displayed[i][j]
                    is_displayed[i][j] = false
                end"""
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
                """collisions[i][j].remove
                if is_displayed[i][j]
                    is_displayed[i][j] = false
                end"""
                next
            end

            denominator = alpha - beta

            collisionx = (alpha * lines[i].x2 - beta * lines[i].x1) / denominator
            collisiony = (alpha * lines[i].y2 - beta * lines[i].y1) / denominator

            """collisions[i][j].add unless is_displayed[i][j]
            collisions[i][j].x = collisionx
            collisions[i][j].y = collisiony"""

            collisions << Circle.new(x: collisionx, y: collisiony, radius: CIRCLE_RADIUS, color: "red")

        end
    end
    text_collisions.text = "Collisions: #{collisions.length}"
    frames += 1
end

show
