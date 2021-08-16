module TestaAppiumDriver
  class ScrollActions


    private

    def w3c_align(with)
      @driver.disable_wait_for_idle
      @driver.disable_implicit_wait
      default_deadzone!

      element = @locator.execute

      case with
      when :top
        page_down if is_aligned?(with, element)
      when :bottom
        page_up if is_aligned?(with, element)
      when :right
        page_right if is_aligned?(with, element)
      when :left
        page_left if is_aligned?(with, element)
      else
        raise "Unsupported align with option: #{with}"
      end

      timeout = 0
      until is_aligned?(with, element) || timeout == 3
        w3c_attempt_align(with)
        timeout += 1
      end

      @driver.enable_implicit_wait
      @driver.enable_wait_for_idle
    end


    def w3c_attempt_align(with)
      case with
      when :top
        y0 = @bounds.bottom_right.y - @deadzone[:bottom]
        y1 = y0 - @align_offset
        x0 = @bounds.width / 2
        x1 = x0
        scroll_direction = :down
      when :bottom
        y0 = @bounds.top_left.y + @deadzone[:top]
        y1 = y0 + @align_offset
        x0 = @bounds.width / 2
        x1 = x0
        scroll_direction = :up
      when :left
        x0 = @bounds.bottom_right.x - @deadzone[:right]
        x1 = x0 - @align_offset
        y0 = @bounds.height / 2
        y1 = y0
        scroll_direction = :right
      when :right
        x0 = @bounds.top_left.x + @deadzone[:top]
        x1 = x0 + @align_offset
        y0 = @bounds.height / 2
        y1 = y0
        scroll_direction = :left
      else
        raise "Unsupported align with option: #{with}"
      end

      x1, y1 = apply_w3c_correction(x1, y1, scroll_direction)
      w3c_action(x0, y0, x1, y1, SCROLL_ACTION_TYPE_SCROLL)
    end


    def w3c_scroll_to(direction)

      rounds = 0
      max_scrolls_reached = false
      until @locator.exists?
        case direction
        when :down
          page_down
        when :right
          page_right
        when :left
          page_left
        when :up
          page_up
        else
          raise "w3c scroll to must provide direction :up, :right, :down or :left"
        end

        rounds += 1
        max_scrolls_reached = true if rounds == @max_scrolls
        break if rounds == @max_scrolls
      end
      raise Selenium::WebDriver::Error::NoSuchElementError if max_scrolls_reached

      @locator
    end


    def w3c_page_or_fling(type, direction)
      @driver.disable_wait_for_idle
      @driver.disable_implicit_wait
      default_deadzone!

      if direction == :down || direction == :up
        if direction == :down
          y0 = @bounds.bottom_right.y - @deadzone[:bottom].to_i
          y1 = @bounds.top_left.y + @deadzone[:top].to_i
        else
          y0 = @bounds.top_left.y + @deadzone[:top].to_i
          y1 = @bounds.bottom_right.y - @deadzone[:bottom].to_i
        end
        x0 = @bounds.width / 2
        x1 = x0
      else
        if direction == :right
          x0 = @bounds.bottom_right.x - @deadzone[:right].to_i
          x1 = @bounds.top_left.x + @deadzone[:left].to_i
        else
          x0 = @bounds.top_left.x + @deadzone[:left].to_i
          x1 = @bounds.bottom_right.x - @deadzone[:right].to_i
        end
        y0 = @bounds.height / 2
        y1 = y0
      end
      x1, y1 = apply_w3c_correction(x1, y1, direction)


      w3c_action(x0, y0, x1, y1, type)

      @driver.enable_implicit_wait
      @driver.enable_wait_for_idle
      @locator
    end


    def w3c_action(x0, y0, x1, y1, type)
      if type == SCROLL_ACTION_TYPE_SCROLL
        duration = 1.8
      elsif type == SCROLL_ACTION_TYPE_FLING
        duration = 0.1
      else
        raise "Unknown scroll action type #{type}"
      end

      action_builder = @driver.action
      f1 = action_builder.add_pointer_input(:touch, "finger1")
      f1.create_pointer_move(duration: 0, x: x0, y: y0, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
      f1.create_pointer_down(:left)

      f1.create_pointer_move(duration: duration, x: x1, y: y1, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
      unless type == SCROLL_ACTION_TYPE_FLING
        # with this move we prevent flinging/overscroll
        f1.create_pointer_move(duration: 0.5, x: x1, y: y1, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
      end
      f1.create_pointer_up(:left)
      puts "Scroll execute[w3c_action]:  #{type}: {x0: #{x0}, y0: #{y0}} => {x1: #{x1}, y1: #{y1}}"
      @driver.perform_actions [f1]
    end


    def apply_w3c_correction(x1, y1, direction)
      y1 -= SCROLL_CORRECTION_W3C if direction == :down
      y1 += SCROLL_CORRECTION_W3C if direction == :up
      x1 -= SCROLL_CORRECTION_W3C if direction == :right
      x1 += SCROLL_CORRECTION_W3C if direction == :left
      [x1, y1]
    end


  end

end