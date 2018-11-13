require 'benchmark'
require_relative 'board'


class Tester

    def initialize(collision_detectors, repeat = 100, max_lines = 9)
        @repeat = repeat
        @max_lines = max_lines
        @collision_detectors = collision_detectors
    end

    def execute_all
        results = Hash.new
        sizes = []
        @collision_detectors.each do |func|
            results[func.name] = []
            (1..@max_lines).each do |i|
                n = 2 ** i
                sizes << n
                radius = 800 / Math.sqrt(n)
                field = Field.new(radius, n)
                lines = Array.new(n) {FakeLines.new}
                board = Board.new(radius, false,800)
                time = without_display(field, lines, board, func)
                p "#{n} #{time}"
                results[func.name] << time
            end
        end
        [results, sizes]
    end

    def without_display(field, lines, board, func)
        collisions = []
        mean_time = 0
        @repeat.times do |x|
            board.update_positions(field, lines)
            mean_time += Benchmark.measure {func.call(board, collisions, lines)}.real
        end
        mean_time / (@repeat)
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