module TestaAppiumDriver
  class ScrollActions

    private
    # @return [Array]
    def w3c_scroll_each(direction, &block)
      elements = []
      begin
        default_deadzone!

        iterations = 0


        if direction.nil?
          scroll_to_start
          if @scrollable.scroll_orientation == :vertical
            direction = :down
          else
            direction = :right
          end
        end

        previous_matches = []
        until is_end_of_scroll?
          matches = @locator.execute(skip_cache: true)
          matches.each_with_index do |m|
            next if previous_matches.include?(m)
            elements << m
            if block_given? # block is given
              block.call(m) # use call to execute the block
            else # the value of block_argument becomes nil if you didn't give a block
              # block was not given
            end
          end
          iterations += 1
          break if !@max_scrolls.nil? && iterations == @max_scrolls
          self.send("page_#{direction}")
          previous_matches = matches
        end
      rescue => e
        raise e

      end
      elements
    end

    def w3c_align(with, scroll_to_find)
      default_deadzone!



      @locator.scroll_to if scroll_to_find

      element = @locator.execute

      timeout = 0
      until is_aligned?(with, element) || timeout == 3
        w3c_attempt_align(with)
        timeout += 1
      end

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

      x1, y1 = apply_w3c_correction(x1, y1, scroll_direction) if @driver.device == :android
      w3c_action(x0, y0, x1, y1, SCROLL_ACTION_TYPE_SCROLL)
    end


    def w3c_scroll_to(direction)

      rounds = 0
      max_scrolls_reached = false
      end_of_scroll_reached = false
      until @locator.exists? || end_of_scroll_reached
        end_of_scroll_reached = is_end_of_scroll?
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
          scroll_to_start
          @previous_elements = nil
          if @scrollable.scroll_orientation == :vertical
            direction = :down
          else
            direction = :right
          end
        end

        rounds += 1

        max_scrolls_reached = true if rounds == @max_scrolls
        break if rounds == @max_scrolls
      end
      raise Selenium::WebDriver::Error::NoSuchElementError if max_scrolls_reached || end_of_scroll_reached
    end

    def w3c_scroll_to_start_or_end(type)
      default_deadzone!

      @previous_elements = nil


      if type == :start
        if @scrollable.scroll_orientation == :vertical
          method = "fling_up"
        else
          method = "fling_left"
        end
      else
        if @scrollable.scroll_orientation == :vertical
          method = "fling_down"
        else
          method = "fling_right"
        end
      end

      iterations = 0
      until is_end_of_scroll? || iterations >= 3
        self.send(method)
        iterations += 1
      end

      # reset the flag for end of scroll elements
      @previous_elements = nil
    end


    def w3c_page_or_fling(type, direction)
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
      x1, y1 = apply_w3c_correction(x1, y1, direction) if @driver.device == :android


      w3c_action(x0, y0, x1, y1, type)

    end


    def w3c_action(x0, y0, x1, y1, type)
      if type == SCROLL_ACTION_TYPE_SCROLL
        duration = 1.8
      elsif type == SCROLL_ACTION_TYPE_FLING
        duration = 0.1
      elsif type == SCROLL_ACTION_TYPE_DRAG
        duration = 3.5
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



    def w3c_drag_to(x0, y0, x1, y1)
      w3c_action(x0, y0, x1, y1, SCROLL_ACTION_TYPE_DRAG)
    end

  end

end