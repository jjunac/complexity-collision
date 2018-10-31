require 'ruby2d'

set title: "Hello Triangle", width: 800, height: 600

Triangle.new(
        x1: 320, y1:  50,
        x2: 540, y2: 430,
        x3: 100, y3: 430,
        color: ['red', 'green', 'blue']
)

show
