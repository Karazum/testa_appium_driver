# frozen_string_literal: true

require 'json'
module TestaAppiumDriver
  class Bounds

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
      @center = TestaAppiumDriver::Coordinates.new(@top_left.x + @width/2, @top_left.y + @height / 2)
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

    # @return [TestaAppiumDriver::Offset]
    def offset
      @offset
    end

    # @return [TestaAppiumDriver::Coordinates]
    def top_left
      @top_left
    end
    # @return [TestaAppiumDriver::Coordinates]
    def bottom_right
      @bottom_right
    end

    # @return [TestaAppiumDriver::Coordinates]
    def center
      @center
    end

    def to_s
      JSON.dump(as_json)
    end

    # @param bounds [String] bounds that driver.attribute("bounds") return
    # @param driver [TestaAppiumDriver::Driver]
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

    def self.from_ios(rect, driver)
      rect = JSON.parse(rect)
      top_left = Coordinates.new(rect["x"], rect["y"])
      bottom_right = Coordinates.new(top_left.x + rect["width"].to_i, top_left.y + rect["height"].to_i)
      ws = driver.window_size
      window_width = ws.width.to_i
      window_height = ws.height.to_i
      Bounds.new(top_left, bottom_right, window_width, window_height)
    end
  end

  #noinspection ALL
  class Coordinates
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


    # @return [Integer]
    def x
      @x
    end

    # @return [Integer]
    def y
      @y
    end
  end


  class Offset
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


    # @return [Integer]
    def top
      @top
    end

    # @return [Integer]
    def right
      @right
    end

    # @return [Integer]
    def bottom
      @bottom
    end

    # @return [Integer]
    def left
      @left
    end

  end
end