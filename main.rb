require 'ruby2d'
require 'optparse'

require_relative 'lib/field'
require_relative 'lib/board'
require_relative 'lib/csv_exporter'
require_relative 'lib/tester'

N = 400
WINDOW_SIZE = 800
# Constants for computation optimisation
RADIUS = 800 / Math.sqrt(N)
LINE_WIDTH = WINDOW_SIZE / 400
CIRCLE_RADIUS = WINDOW_SIZE / 200

set title: "Collision benchmark", width: WINDOW_SIZE, height: WINDOW_SIZE

# Parameters


"" "collisions = Array.new(N) { Array.new(N) { nil } }
is_displayed = Array.new(N) { Array.new(N) { false } }
N.times do |i|
    (i+1...N).each do |j|
        collisions[i][j] = Circle.new(x: 0, y: 0, radius: CIRCLE_RADIUS, color: 'red')
        collisions[i][j].remove
    end
end" ""




def naive_collisions(board, collisions, lines)
    (lines.length - 1).times do |i|
        abx = lines[i].x2 - lines[i].x1
        aby = lines[i].y2 - lines[i].y1
        (i + 1...lines.length).each do |j|
            collide = board.collide?(abx, aby, lines[i], lines[j])
            if collide
                board.add_collision(collide, collisions)
            end
        end
    end
end


def scan_line(board, collisions, lines)
    entries = lines.sort {|a, b| [a.x1, a.x2].min <=> [b.x1, b.x2].min}
    (entries.length - 1).times do |i|
        abx = lines[i].x2 - lines[i].x1
        aby = lines[i].y2 - lines[i].y1
        p = [lines[i].x1, lines[i].x2].min
        (lines.length - 1).times do |j|
            if (lines[j].x1 < p && p < lines[j].x2) or (lines[j].x2 < p && p < lines[j].x1)
                collide = board.collide?(abx, aby, lines[i], lines[j])
                if collide
                    board.add_collision(collide, collisions)
                end
            end
        end
    end
end

def scan_line_without_sort(board, collisions, lines)
    (lines.length - 1).times do |i|
        p lines[i].x1
        abx = lines[i].x2 - lines[i].x1
        aby = lines[i].y2 - lines[i].y1
        p = [lines[i].x1, lines[i].x2].min
        (lines.length - 1).times do |j|
            if (lines[j].x1 < p && p < lines[j].x2) or (lines[j].x2 < p && p < lines[j].x1)
                collide = board.collide?(abx, aby, lines[i], lines[j])
                if collide
                    board.add_collision(collide, collisions)
                end
            end
        end
    end
end

def with_display(field, lines)
    collisions = []
    Rectangle.new(x: 0, y: 0, width: 80, height: 26, color: 'silver', z: 10)
    text_collisions = Text.new("", x: 2, y: 2, size: 10, color: 'black', z: 11)
    text_fps = Text.new("FPS: ", x: 2, y: 14, size: 10, color: 'black', z: 11)
    board = Board.new(RADIUS, WINDOW_SIZE)
    last_fps = Time.now.to_f
    frames = 0
    update do
        # Movement and display
        board.update_positions(field, lines)
        # Collision detection

        collisions.each(&:remove)
        collisions = []

        scan_line(board, collisions, lines)
        now = Time.now.to_f
        if now > last_fps + 1
            text_fps.text = "FPS: #{frames}"
            frames = 0
            last_fps = now
        end
        if frames % 25 == 0
            text_collisions.text = "Collisions: #{collisions.length}"
        end
        frames += 1
    end

    show
end


options = {}
OptionParser.new do |opt|
    opt.on('--bench') {|| options[:bench] = true}
    opt.on('-b') {|| options[:bench] = true}
    opt.on('--algo algorithm') {|o| options[:algo] = o.to_sym}
end.parse!
if options[:bench]
    if !options[:algo]
        tester = Tester.new([method(:scan_line), method(:naive_collisions)], 100, 11)
    else
        tester = Tester.new([method(options[:algo])], 100, 11)
    end
    csv_exporter = CSVExporter.new
    results, sizes = tester.execute_all
    csv_exporter.export_map("test.csv", sizes, results)
else
    field = Field.new(RADIUS, N)
    lines = Array.new(N) {Line.new(width: LINE_WIDTH, color: 'white')}
    with_display(field, lines)
end


