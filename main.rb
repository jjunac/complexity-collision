require 'optparse'
require 'algorithms'
require 'forwardable'

require_relative 'lib/board'
require_relative 'lib/csv_exporter'
require_relative 'lib/tester'
require_relative 'lib/quad_tree'

N = 400
WINDOW_SIZE = 800
# Constants for computation optimisation
RADIUS = 800 / Math.sqrt(N)
LINE_WIDTH = WINDOW_SIZE / 400
CIRCLE_RADIUS = WINDOW_SIZE / 200


# Parameters

class GneeeLine
    extend Forwardable

    attr_accessor :line, :leftmost, :rightmost
    def_delegators :@line, :x1
    def_delegators :@line, :x2
    def_delegators :@line, :y1
    def_delegators :@line, :y2

    def initialize(line)
        @line = line
        if @line.x1 < @line.x2
            @leftmost, @rightmost = @line.x1, @line.x2
        else
            @leftmost, @rightmost = @line.x2, @line.x1
        end
    end

    def <=>(another)
        @rightmost <=> another.rightmost
    end
end

def true_scan_line(board, collisions)
    lines = board.lines
    tree = Containers::CRBTreeMap.new
    entries = lines.map {|l| GneeeLine.new l}
    entries.sort! {|a, b| a.leftmost <=> b.leftmost}
    until entries.empty? do
        l1 = entries.shift

        abx = l1.x2 - l1.x1
        aby = l1.y2 - l1.y1
        tree.each do |_, l2|
            collide = board.collide?(abx, aby, l1, l2)
            if collide
                board.add_collision(collide, collisions)
            end
        end

        if entries.empty?
            break
        end
        tree[l1.rightmost] = l1
        while tree.min_key < entries.first.leftmost
            tree.delete_min
        end
    end

end


def naive_collisions(board, collisions)
    lines = board.lines
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

def quadtree(board, collisions)
    lines = board.lines
    w = board.window_size
    quad_tree = QuadTree.new(BoundingBox.new([w / 2, w / 2], w / 2 + 200))
    lines.each {|l| quad_tree.insert_line(l)}
    lines.each do |first_line|
        abx = first_line.x2 - first_line.x1
        aby = first_line.y2 - first_line.y1
        other_lines = quad_tree.query_range(first_line)
        other_lines.each do |line|
            collide = board.collide?(abx, aby, first_line, line)
            if collide
                board.add_collision(collide, collisions)
            end
        end
    end
end


def hash_table(board, collisions)
    cell_size = [board.radius * 2, board.window_size / 2].min
    size = (board.window_size / cell_size).ceil
    grid = Array.new(size, Array.new(size))
    grid.each {|col| col.length.times.each {|i| col[i] = []}}
    board.lines.each do |line|
        points = [[(line.x1 / cell_size).round, (line.y1 / cell_size).round], [(((line.x1 + line.x2) / 2) / cell_size).round, (((line.y1 + line.y2) / 2) / cell_size).round],
                  [(line.x2 / cell_size).round, (line.y2 / cell_size).round]]
        cells = []
        points.each do |point|
            x = [point[0], size - 1].min
            column = grid[x]
            y = [point[1], size - 1].min
            if !cells.include?(line)
                column[y].push(line)
                cells.push(line)
            end
        end
    end
    grid.each do |col|
        col.each do |cell|
            (cell.length - 1).times do |i|
                first_line = cell[i]
                (i + 1...cell.length).each do |j|
                    abx = first_line.x2 - first_line.x1
                    aby = first_line.y2 - first_line.y1
                    collide = board.collide?(abx, aby, first_line, cell[j])
                    if collide
                        board.add_collision(collide, collisions)
                    end
                end
            end
        end
    end

end


def scan_line(board, collisions)
    lines = board.lines
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

def scan_line_without_sort(board, collisions)
    lines = board.lines
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

def with_display(method)
    collisions = []
    Rectangle.new(x: 0, y: 0, width: 80, height: 26, color: 'silver', z: 10)
    text_collisions = Text.new("", x: 2, y: 2, size: 10, color: 'black', z: 11)
    text_fps = Text.new("FPS: ", x: 2, y: 14, size: 10, color: 'black', z: 11)
    board = Board.new(RADIUS, WINDOW_SIZE)
    last_fps = Time.now.to_f
    frames = 0
    update do
        # Movement and display
        board.update_positions
        # Collision detection

        collisions.each(&:remove)
        collisions = []

        method.call(board, collisions)
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
        tester = Tester.new([method(:true_scan_line), method(:scan_line), method(:naive_collisions)], 100, 13)
    else
        tester = Tester.new([method(options[:algo])], 100, 14)
    end
    csv_exporter = CSVExporter.new
    results, sizes = tester.execute_all
    csv_exporter.export_map("test.csv", sizes, results)
else
    require 'ruby2d'
    set title: "Collision benchmark", width: WINDOW_SIZE, height: WINDOW_SIZE

    with_display(method(:hash_table))
end


