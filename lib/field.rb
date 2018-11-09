require 'forwardable'
require_relative 'segment'

class Field
    extend Forwardable

    def_delegators :@segments, :each
    def_delegators :@segments, :length
    def_delegators :@segments, :[]


    def initialize(nb_segments=1)
        @segments = Array.new(nb_segments) do
            Segment.new(
                    rand,
                    rand,
                    rand * 2 - 1,
                    rand * 2 - 1,
                    rand * 2 * Math::PI,
                    rand * 2 * Math::PI
            )
        end
    end

end