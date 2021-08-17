module TestaAppiumDriver
  #noinspection RubyTooManyMethodsInspection
  class Locator

    # @param [Float] duration in seconds
    def long_tap(duration = LONG_TAP_DURATION)
      action_builder = @driver.action
      b = bounds
      f1 = action_builder.add_pointer_input(:touch, "finger1")
      f1.create_pointer_move(duration: 0, x: b.center.x, y: b.center.y, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
      f1.create_pointer_down(:left)
      f1.create_pause(duration)
      f1.create_pointer_up(:left)
      puts "long tap execute:  {x: #{b.center.x}, y: #{b.center.y}}"
      @driver.perform_actions [f1]
    end

    # @return [Array] array of [Selenium::WebDriver::Element]
    def each(deadzone: nil, skip_scroll_to_start: false, &block)
      raise "Each can only be performed on multiple elements locator" if @single
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             default_scroll_strategy: @default_scroll_strategy)
      sa.each(skip_scroll_to_start, &block)
    end


    # Aligns element (by default) on top of the scrollable container, if the element does not exists it will scroll to find it
    # @return [TestaAppiumDriver::Locator]
    def align(with = :top, deadzone: nil, raise: false)
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             default_scroll_strategy: @default_scroll_strategy,
                             raise: raise)
      sa.align(with)
      self
    end

    # Aligns element on top of the scrollable container, if the element does not exists it will scroll to find it
    # @return [TestaAppiumDriver::Locator]
    def align_top(deadzone: nil)
      align(:top, deadzone: deadzone)
    end

    # Aligns element on bottom of the scrollable container, if the element does not exists it will scroll to find it
    # @return [TestaAppiumDriver::Locator]
    def align_bottom(deadzone: nil)
      align(:bottom, deadzone: deadzone)
    end

    # Aligns element on left of the scrollable container, if the element does not exists it will scroll to find it
    # @return [TestaAppiumDriver::Locator]
    def align_left(deadzone: nil)
      align(:left, deadzone: deadzone)
    end

    # Aligns element on right of the scrollable container, if the element does not exists it will scroll to find it
    # @return [TestaAppiumDriver::Locator]
    def align_right(deadzone: nil)
      align(:right, deadzone: deadzone)
    end

    # Aligns element (by default) on top of the scrollable container, if the element does not exists it raise an exception
    # @return [TestaAppiumDriver::Locator]
    def align!(with = :top, deadzone: nil)
      align(with, deadzone: deadzone, raise: true)
    end

    # Aligns element on top of the scrollable container, if the element does not exists it raise an exception
    # @return [TestaAppiumDriver::Locator]
    def align_top!(deadzone: nil)
      align(:top, deadzone: deadzone, raise: true)
    end

    # Aligns element on bottom of the scrollable container, if the element does not exists it raise an exception
    # @return [TestaAppiumDriver::Locator]
    def align_bottom!(deadzone: nil)
      align(:bottom, deadzone: deadzone, raise: true)
    end

    # Aligns element on left of the scrollable container, if the element does not exists it raise an exception
    # @return [TestaAppiumDriver::Locator]
    def align_left!(deadzone: nil)
      align(:left, deadzone: deadzone, raise: true)
    end

    # Aligns element on right of the scrollable container, if the element does not exists it raise an exception
    # @return [TestaAppiumDriver::Locator]
    def align_right!(deadzone: nil)
      align(:right, deadzone: deadzone, raise: true)
    end


    # First scrolls to the beginning of the scrollable container and then scrolls down until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_to(deadzone: nil, max_scrolls: nil, direction: nil)
      _scroll_to(deadzone, max_scrolls, direction)
    end


    # Scrolls down until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_down_to(deadzone: nil, max_scrolls: nil)
      _scroll_to(deadzone, max_scrolls, :down)
    end

    # Scrolls up until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_up_to(deadzone: nil, max_scrolls: nil)
      _scroll_to(deadzone, max_scrolls, :up)
    end

    # Scrolls right until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_right_to(deadzone: nil, max_scrolls: nil)
      _scroll_to(deadzone, max_scrolls, :right)
    end


    # Scrolls left until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_left_to(deadzone: nil, max_scrolls: nil)
      _scroll_to(deadzone, max_scrolls, :left)
    end

    # Scrolls to the start of the scrollable container (top on vertical container, left on horizontal)
    # @return [TestaAppiumDriver::Locator]
    def scroll_to_start(deadzone: nil)
      _scroll_to_start_or_end(:start, deadzone)
    end

    # Scrolls to the end of the scrollable container (bottom on vertical container, right on horizontal)
    # @return [TestaAppiumDriver::Locator]
    def scroll_to_end(deadzone: nil)
      _scroll_to_start_or_end(:end, deadzone)
    end


    # @return [TestaAppiumDriver::Locator]
    def page_down(deadzone: nil)
      _page(:down, deadzone)
    end

    # @return [TestaAppiumDriver::Locator]
    def page_up(deadzone: nil)
      _page(:up, deadzone)
    end

    # @return [TestaAppiumDriver::Locator]
    def page_left(deadzone: nil)
      _page(:left, deadzone)
    end

    # @return [TestaAppiumDriver::Locator]
    def page_right(deadzone: nil)
      _page(:right, deadzone)
    end

    # @return [TestaAppiumDriver::Locator]
    def fling_down(deadzone: nil)
      _fling(:down, deadzone)
    end

    # @return [TestaAppiumDriver::Locator]
    def fling_up(deadzone: nil)
      _fling(:up, deadzone)
    end

    # @return [TestaAppiumDriver::Locator]
    def fling_left(deadzone: nil)
      _fling(:left, deadzone)
    end

    # @return [TestaAppiumDriver::Locator]
    def fling_right(deadzone: nil)
      _fling(:right, deadzone)
    end


    # @param [TestaAppiumDriver::Locator, Hash, Selenium::WebDriver::Element, String] to
    #noinspection RubyYardParamTypeMatch,RubyScope
    def drag_to(to)
      if !to.kind_of?(Selenium::WebDriver::Element) && !to.kind_of?(TestaAppiumDriver::Locator) && !to.kind_of?(Hash)
        raise "Parameter not accepted, acceptable instances of [TestaAppiumDriver::Locator, Hash, Selenium::WebDriver::Element]"
      end
      if to.kind_of?(Selenium::WebDriver::Element)
        bounds = TestaAppiumDriver::Bounds.from_android(to.bounds, @driver)
        x = bounds.center.x
        y = bounds.center.y
      end
      if to.kind_of?(TestaAppiumDriver::Locator)
        bounds = to.bounds
        x = bounds.center.x
        y = bounds.center.y
      end
      if to.kind_of?(Hash)
        raise "Missing x coordinate" if to[:x].nil?
        raise "Missing y coordinate" if to[:y].nil?
        x = to[:x]
        y = to[:y]
      end
      _drag_to(x, y)
    end

    def drag_by(amount, direction: :top)
      b = bounds
      x = b.center.x
      y = b.center.y
      case direction
      when :top
        y -= amount.to_i
      when :bottom
        y += amount.to_i
      when :left
        x -= amount.to_i
      when :right
        x += amount.to_i
      else
        raise "Unknown direction #{direction}"
      end
      _drag_to(x, y)
    end



    private
    def _drag_to(x, y)
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             default_scroll_strategy: @default_scroll_strategy)
      sa.drag_to(x, y)
      self
    end
    def _page(direction, deadzone)
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             direction: direction.to_sym,
                             default_scroll_strategy: @default_scroll_strategy)
      sa.send("page_#{direction}")
      self
    end

    def _fling(direction, deadzone)
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             direction: direction.to_sym,
                             default_scroll_strategy: @default_scroll_strategy)
      sa.send("fling_#{direction}")
      self
    end

    def _scroll_to_start_or_end(type, deadzone)
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             direction: :left,
                             default_scroll_strategy: @default_scroll_strategy)
      if type == :start
        sa.scroll_to_start
      else
        sa.scroll_to_end
      end
      self
    end

    def _scroll_to(deadzone, max_scrolls, direction)
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             max_scrolls: max_scrolls,
                             direction: direction,
                             default_scroll_strategy: @default_scroll_strategy)
      sa.scroll_to
      self
    end
  end
end