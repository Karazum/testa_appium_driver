module TestaAppiumDriver
  class Locator

    def self.define_page_or_fling_methods(type, direction)
      define_method "#{type}_#{direction}" do |deadzone: nil|
        sa = ScrollActions.new(@scrollable_locator, locator: self, deadzone: deadzone, direction: direction.to_sym)
        sa.send("#{type}_#{direction}")
      end
    end


    def align(with = :top, deadzone: nil)
      sa = ScrollActions.new(@scrollable_locator, locator: self, deadzone: deadzone)
      sa.align(with)
    end

    def align_top(deadzone: nil)
      align(:top, deadzone: deadzone)
    end

    def align_bottom(deadzone: nil)
      align(:bottom, deadzone: deadzone)
    end

    def align_left(deadzone: nil)
      align(:left, deadzone: deadzone)
    end

    def align_right(deadzone: nil)
      align(:right, deadzone: deadzone)
    end


    def scroll_to(deadzone: nil, max_scrolls: nil, direction: nil)
      sa = ScrollActions.new(@scrollable_locator, locator: self, deadzone: deadzone, max_scrolls: max_scrolls, direction: direction)
      sa.scroll_to
    end


    def scroll_down_to(deadzone: nil, max_scrolls: nil)
      sa = ScrollActions.new(@scrollable_locator, locator: self, deadzone: deadzone, max_scrolls: max_scrolls, direction: :down)
      sa.scroll_down_to
    end

    def scroll_up_to(deadzone: nil, max_scrolls: nil)
      sa = ScrollActions.new(@scrollable_locator, locator: self, deadzone: deadzone, max_scrolls: max_scrolls, direction: :up)
      sa.scroll_up_to
    end

    def scroll_right_to(deadzone: nil, max_scrolls: nil)
      sa = ScrollActions.new(@scrollable_locator, locator: self, deadzone: deadzone, max_scrolls: max_scrolls, direction: :right)
      sa.scroll_right_to
    end


    def scroll_left_to(deadzone: nil, max_scrolls: nil)
      sa = ScrollActions.new(@scrollable_locator, locator: self, deadzone: deadzone, max_scrolls: max_scrolls, direction: :left)
      sa.scroll_left_to
    end


    define_page_or_fling_methods :page, :down
    define_page_or_fling_methods :page, :left
    define_page_or_fling_methods :page, :right
    define_page_or_fling_methods :page, :up

    define_page_or_fling_methods :fling, :down
    define_page_or_fling_methods :fling, :left
    define_page_or_fling_methods :fling, :right
    define_page_or_fling_methods :fling, :up


  end
end