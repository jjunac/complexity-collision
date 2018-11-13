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
                board = Board.new(radius, n, false, 800)
                time = without_display(board, func)
                p "#{n} #{time}"
                results[func.name] << time
            end
        end
        [results, sizes]
    end

    def without_display(board, func)
        collisions = []
        mean_time = 0
        @repeat.times do |x|
            board.update_positions
            mean_time += Benchmark.measure {func.call(board, collisions)}.real
        end
        mean_time / (@repeat)
    end
end