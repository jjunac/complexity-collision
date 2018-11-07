class Segment

    attr_accessor :x, :y, :vx, :vy, :angle, :radial_speed

    def initialize(x, y, vx, vy, angle, radial_speed)
        @x = x
        @y = y
        @vx = vx
        @vy = vy
        @angle = angle
        @radial_speed = radial_speed
    end

end