module TestaAppiumDriver
  #noinspection RubyTooManyMethodsInspection
  class Locator

    # performs a long tap on the retrieved element
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


    # scrolls to the start of the scrollable containers and scrolls to the end,
    # everytime a locator element is found the given block is executed
    # @return [Array<Selenium::WebDriver::Element>]
    def each(top: nil, bottom: nil, right: nil, left: nil, direction: nil, &block)
      deadzone = _process_deadzone(top, bottom, right, left)
      raise "Each can only be performed on multiple elements locator" if @single
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             default_scroll_strategy: @default_scroll_strategy)
      if direction.nil?
        sa.each(&block)
      else
        sa.send("each_#{direction}", &block)
      end
    end

    # scrolls down from the current page view (without prior scrolling to the top) and
    # everytime a locator element is found the given block is executed
    # @return [Array<Selenium::WebDriver::Element>]
    def each_down(top: nil, bottom: nil, right: nil, left: nil, &block)
      each(top: top, bottom: bottom, right: right, left: left, direction: :down, &block)
    end

    # scrolls up from the current page view (without prior scrolling to the bottom) and
    # everytime a locator element is found the given block is executed
    # @return [Array<Selenium::WebDriver::Element>]
    def each_up(top: nil, bottom: nil, right: nil, left: nil, &block)
      each(top: top, bottom: bottom, right: right, left: left, direction: :up, &block)
    end

    # scrolls right from the current page view (without prior scrolling to the left) and
    # everytime a locator element is found the given block is executed
    # @return [Array<Selenium::WebDriver::Element>]
    def each_right(top: nil, bottom: nil, right: nil, left: nil, &block)
      each(top: top, bottom: bottom, right: right, left: left, direction: :right, &block)
    end

    # scrolls left from the current page view (without prior scrolling to the right) and
    # everytime a locator element is found the given block is executed
    # @return [Array<Selenium::WebDriver::Element>]
    def each_left(top: nil, bottom: nil, right: nil, left: nil, &block)
      each(top: top, bottom: bottom, right: right, left: left, direction: :left, &block)
    end


    # Aligns element (by default) on top of the scrollable container, if the element does not exists it will scroll to find it
    # The element is aligned if the the distance from the top/bottom/right/left of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align(with = :top, top: nil, bottom: nil, right: nil, left: nil, scroll_to_find: false)
      deadzone = _process_deadzone(top, bottom, right, left)
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             default_scroll_strategy: @default_scroll_strategy)
      sa.align(with, scroll_to_find)
      self
    end

    # Aligns element on top of the scrollable container, if the element does not exists it will scroll to find it
    # The element is aligned if the the distance from the top of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align_top(top: nil, bottom: nil, right: nil, left: nil)
      align(:top, top: top, bottom: bottom, right: right, left: left)
    end

    # Aligns element on bottom of the scrollable container, if the element does not exists it will scroll to find it
    # The element is aligned if the the distance from the bottom of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align_bottom(top: nil, bottom: nil, right: nil, left: nil)
      align(:bottom, top: top, bottom: bottom, right: right, left: left)
    end

    # Aligns element on left of the scrollable container, if the element does not exists it will scroll to find it
    # The element is aligned if the the distance from the left of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align_left(top: nil, bottom: nil, right: nil, left: nil)
      align(:left, top: top, bottom: bottom, right: right, left: left)
    end

    # Aligns element on right of the scrollable container, if the element does not exists it will scroll to find it
    # The element is aligned if the the distance from the right of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align_right(top: nil, bottom: nil, right: nil, left: nil)
      align(:right, top: top, bottom: bottom, right: right, left: left)
    end

    # Aligns element (by default) on top of the scrollable container, if the element does not exists it raise an exception
    # The element is aligned if the the distance from the top/bottom/right/left of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align!(with = :top, top: nil, bottom: nil, right: nil, left: nil)
      align(with, top: top, bottom: bottom, right: right, left: left, scroll_to_find: true)
    end

    # Aligns element on top of the scrollable container, if the element does not exists it raise an exception
    # The element is aligned if the the distance from the top of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align_top!(top: nil, bottom: nil, right: nil, left: nil)
      align(:top, top: top, bottom: bottom, right: right, left: left, scroll_to_find: true)
    end

    # Aligns element on bottom of the scrollable container, if the element does not exists it raise an exception
    # The element is aligned if the the distance from the bottom of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align_bottom!(top: nil, bottom: nil, right: nil, left: nil)
      align(:bottom, top: top, bottom: bottom, right: right, left: left, scroll_to_find: true)
    end

    # Aligns element on left of the scrollable container, if the element does not exists it raise an exception
    # The element is aligned if the the distance from the left of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align_left!(top: nil, bottom: nil, right: nil, left: nil)
      align(:left, top: top, bottom: bottom, right: right, left: left, scroll_to_find: true)
    end

    # Aligns element on right of the scrollable container, if the element does not exists it raise an exception
    # The element is aligned if the the distance from the right of the scrollable container is less than [TestaAppiumDriver::SCROLL_ALIGNMENT_THRESHOLD]
    # If the distance is greater than the threshold, it will attempt to realign it up to 2 more times.
    # The retry mechanism allows alignment even for dynamic layouts when elements are hidden/show when scrolling to certain direction
    # @return [TestaAppiumDriver::Locator]
    def align_right!(top: nil, bottom: nil, right: nil, left: nil)
      align(:right, top: top, bottom: bottom, right: right, left: left, scroll_to_find: true)
    end


    # First scrolls to the beginning of the scrollable container and then scrolls down until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_to(top: nil, bottom: nil, right: nil, left: nil, max_scrolls: nil, direction: nil)
      if direction
        _scroll_dir_to(_process_deadzone(top, bottom, right, left), max_scrolls, direction)
      else
        _scroll_to(_process_deadzone(top, bottom, right, left), max_scrolls)
      end
    end


    # Scrolls down until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_down_to(top: nil, bottom: nil, right: nil, left: nil, max_scrolls: nil)
      _scroll_dir_to(_process_deadzone(top, bottom, right, left), max_scrolls, :down)
    end

    # Scrolls up until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_up_to(top: nil, bottom: nil, right: nil, left: nil, max_scrolls: nil)
      _scroll_dir_to(_process_deadzone(top, bottom, right, left), max_scrolls, :up)
    end

    # Scrolls right until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_right_to(top: nil, bottom: nil, right: nil, left: nil, max_scrolls: nil)
      _scroll_dir_to(_process_deadzone(top, bottom, right, left), max_scrolls, :right)
    end


    # Scrolls left until element is found or end is reached
    # @return [TestaAppiumDriver::Locator]
    def scroll_left_to(top: nil, bottom: nil, right: nil, left: nil, max_scrolls: nil)
      _scroll_dir_to(_process_deadzone(top, bottom, right, left), max_scrolls, :left)
    end

    # Scrolls to the start of the scrollable container (top on vertical container, left on horizontal)
    # @return [TestaAppiumDriver::Locator]
    def scroll_to_start(top: nil, bottom: nil, right: nil, left: nil)
      _scroll_to_start_or_end(:start, _process_deadzone(top, bottom, right, left))
    end

    # Scrolls to the end of the scrollable container (bottom on vertical container, right on horizontal)
    # @return [TestaAppiumDriver::Locator]
    def scroll_to_end(top: nil, bottom: nil, right: nil, left: nil)
      _scroll_to_start_or_end(:end, _process_deadzone(top, bottom, right, left))
    end


    # @return [TestaAppiumDriver::Locator]
    def page_down(top: nil, bottom: nil, right: nil, left: nil)
      _page(:down, _process_deadzone(top, bottom, right, left))
    end

    # @return [TestaAppiumDriver::Locator]
    def page_up(top: nil, bottom: nil, right: nil, left: nil)
      _page(:up, _process_deadzone(top, bottom, right, left))
    end

    # @return [TestaAppiumDriver::Locator]
    def page_left(top: nil, bottom: nil, right: nil, left: nil)
      _page(:left, _process_deadzone(top, bottom, right, left))
    end

    # @return [TestaAppiumDriver::Locator]
    def page_right(top: nil, bottom: nil, right: nil, left: nil)
      _page(:right, _process_deadzone(top, bottom, right, left))
    end

    # @return [TestaAppiumDriver::Locator]
    def fling_down(top: nil, bottom: nil, right: nil, left: nil)
      _fling(:down, _process_deadzone(top, bottom, right, left))
    end

    # @return [TestaAppiumDriver::Locator]
    def fling_up(top: nil, bottom: nil, right: nil, left: nil)
      _fling(:up, _process_deadzone(top, bottom, right, left))
    end

    # @return [TestaAppiumDriver::Locator]
    def fling_left(top: nil, bottom: nil, right: nil, left: nil)
      _fling(:left, _process_deadzone(top, bottom, right, left))
    end

    # @return [TestaAppiumDriver::Locator]
    def fling_right(top: nil, bottom: nil, right: nil, left: nil)
      _fling(:right, _process_deadzone(top, bottom, right, left))
    end

    def drag_up_by(amount)
      drag_by(amount, direction: :top)
    end

    def drag_down_by(amount)
      drag_by(amount, direction: :bottom)
    end

    def drag_left_by(amount)
      drag_by(amount, direction: :left)
    end

    def drag_right_by(amount)
      drag_by(amount, direction: :right)
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
      _drag_to(bounds.center.x, bounds.center.y, x, y)
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
      _drag_to(b.center.x, b.center.y, x, y)
    end



    private
    def _process_deadzone(top, bottom, right, left)
      deadzone = nil
      if !top.nil? || !bottom.nil? || !right.nil? || !left.nil?
        deadzone = {}
        deadzone[:top] = top unless top.nil?
        deadzone[:bottom] = bottom unless bottom.nil?
        deadzone[:right] = right unless right.nil?
        deadzone[:left] = left unless left.nil?
      end
      deadzone
    end

    def _drag_to(x0, y0, x1, y1)
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             default_scroll_strategy: @default_scroll_strategy)
      sa.drag_to(x0, y0, x1, y1)
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
                             default_scroll_strategy: @default_scroll_strategy)
      if type == :start
        sa.scroll_to_start
      else
        sa.scroll_to_end
      end
      self
    end

    def _scroll_to(deadzone, max_scrolls)
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             max_scrolls: max_scrolls,
                             default_scroll_strategy: @default_scroll_strategy)
      sa.scroll_to
      self
    end

    def _scroll_dir_to(deadzone, max_scrolls, direction)
      deadzone = @scrollable_locator.scroll_deadzone if deadzone.nil? && !@scrollable_locator.nil?
      sa = ScrollActions.new(@scrollable_locator,
                             locator: self,
                             deadzone: deadzone,
                             max_scrolls: max_scrolls,
                             default_scroll_strategy: @default_scroll_strategy)

      sa.send("scroll_#{direction}_to")
      self
    end
  end
end