require 'json'
module TestaAppiumDriver
  class Bounds
    attr_reader :top_left
    attr_reader :bottom_right
    attr_reader :width
    attr_reader :height
    attr_reader :offset

    # @param top_left [Coordinates]
    # @param bottom_right [Coordinates]
    # @param window_width [Integer]
    # @param window_height [Integer]
    def initialize(top_left, bottom_right, window_width, window_height)
      @top_left = top_left
      @bottom_right = bottom_right
      @width = bottom_right.x - top_left.x
      @height = bottom_right.y - top_left.y
      @offset = Offset.new(self, window_width, window_height)
    end

    def as_json
      {
        width: @width,
        height: @height,
        top_left: @top_left.as_json,
        bottom_right: @bottom_right.as_json,
        offset: @offset.as_json
      }
    end

    def to_s
      JSON.dump(as_json)
    end

    # @param bounds [String] bounds that driver.attribute("bounds") return
    # @param driver [TestaAppiumDriver]
    def self.from_android(bounds, driver)
      matches = bounds.match(/\[(\d+),(\d+)\]\[(\d+),(\d+)\]/)
      raise "Unexpected bounds: #{bounds}" unless matches

      captures = matches.captures
      top_left = Coordinates.new(captures[0], captures[1])
      bottom_right = Coordinates.new(captures[2], captures[3])
      ws = driver.window_size
      window_width = ws.width.to_i
      window_height = ws.height.to_i
      Bounds.new(top_left, bottom_right, window_width, window_height)
    end
  end

  #noinspection ALL
  class Coordinates
    attr_reader :x
    attr_reader :y

    def initialize(x, y)
      @x = x.to_i
      @y = y.to_i
    end

    def as_json
      {
        x: @x,
        y: @y
      }
    end
  end

  class Offset
    attr_reader :top
    attr_reader :right
    attr_reader :bottom
    attr_reader :left

    def initialize(bounds, window_width, window_height)
      @top = bounds.top_left.y
      @right = window_width - bounds.bottom_right.x
      @bottom = window_height - bounds.bottom_right.y
      @left = bounds.top_left.x
    end

    def as_json
      {
        top: @top,
        right: @right,
        bottom: @bottom,
        left: @left
      }
    end
  end
end