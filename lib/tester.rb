require 'benchmark'
require_relative 'board'


class Tester

    def initialize(collision_detectors, repeat = 1000, max_lines = 9)
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
                lines = Array.new(n) {Line.new(width: LINE_WIDTH, color: 'white')}
                board = Board.new(radius, 1080)
                results[func.name] << without_display(field, lines, board, func)
            end
        end
        [results, sizes]
    end

    def without_display(field, lines, board, func)
        collisions = []
        mean_time = 0
        @repeat.times do |x|
            board.update_positions(field, lines)
            collisions.each(&:remove)
            collisions = []
            mean_time += Benchmark.measure {func.call(board, collisions, lines)}.real
            end
        mean_time / (@repeat * lines.length)
    end
end