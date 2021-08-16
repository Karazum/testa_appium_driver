require_relative 'scroll_actions/json_wire_scroll_actions'
require_relative 'scroll_actions/w3c_scroll_actions'
require_relative 'scroll_actions/uiautomator_scroll_actions'

module TestaAppiumDriver
  #noinspection RubyResolve
  class ScrollActions

    def initialize(scrollable, params = {})
      @scrollable = scrollable
      @locator = params[:locator]
      @deadzone = params[:deadzone]
      @direction = params[:direction]
      @max_scrolls = params[:max_scrolls]
      @driver = @locator.driver


      if @scrollable.nil? || (@scrollable.strategy == FIND_STRATEGY_XPATH && @deadzone.nil?)
        # if we dont have a scrollable element or if we do have it, but it is not compatible with uiautomator
        # then find first scrollable in document
        @scrollable = @driver.scrollable
      end

      @strategy = nil
      if @scrollable.strategy == FIND_STRATEGY_XPATH || # uiautomator cannot resolve scrollable from a xpath locator
          !@deadzone.nil?
        @strategy = SCROLL_STRATEGY_W3C
      end

      @bounds = @scrollable.bounds

    end


    def align(with)
      w3c_align(with)
      @locator
    end


    def scroll_to
      if @strategy == SCROLL_STRATEGY_UIAUTOMATOR || @strategy.nil?
        # we have direction enabled, uiautomator does not support direction specific element search
        if @locator.strategy != FIND_STRATEGY_XPATH
          uiautomator_scroll_to
        else
          raise "scroll_to cannot use xpath find strategy with uiautomator scroll strategy"
        end
      elsif @strategy == SCROLL_STRATEGY_W3C
        raise "scroll_to is not supported for w3c scroll strategy. Either remove deadzone, or use [scroll_down_to, scroll_up_to, scroll_left_to, scroll_right_to]"
      end
    end

    def scroll_down_to
      if @strategy == SCROLL_STRATEGY_W3C || @strategy.nil?
        # we have direction enabled, uiautomator does not support direction specific element search
        w3c_scroll_to(:down)
      elsif @strategy == SCROLL_STRATEGY_UIAUTOMATOR
        raise "scroll_down_to is not supported for uiautomator scroll strategy. Use scroll_to without deadzone"
      end
    end

    def scroll_up_to
      if @strategy == SCROLL_STRATEGY_W3C || @strategy.nil?
        # we have direction enabled, uiautomator does not support direction specific element search
        w3c_scroll_to(:up)
      elsif @strategy == SCROLL_STRATEGY_UIAUTOMATOR
        raise "scroll_up_to is not supported for uiautomator scroll strategy. Use scroll_to without deadzone"
      end
    end

    def scroll_right_to
      if @strategy == SCROLL_STRATEGY_W3C || @strategy.nil?
        # we have direction enabled, uiautomator does not support direction specific element search
        w3c_scroll_to(:right)
      elsif @strategy == SCROLL_STRATEGY_UIAUTOMATOR
        raise "scroll_right_to is not supported for uiautomator scroll strategy. Use scroll_to without deadzone"
      end
    end

    def scroll_left_to
      if @strategy == SCROLL_STRATEGY_W3C || @strategy.nil?
        # we have direction enabled, uiautomator does not support direction specific element search
        w3c_scroll_to(:left)
      elsif @strategy == SCROLL_STRATEGY_UIAUTOMATOR
        raise "scroll_left_to is not supported for uiautomator scroll strategy. Use scroll_to without deadzone"
      end
    end


    def page_down
      if @strategy == SCROLL_STRATEGY_UIAUTOMATOR || @strategy.nil?
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :down)
      elsif @strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :down)
      end
    end

    def page_right
      if @strategy == SCROLL_STRATEGY_UIAUTOMATOR || @strategy.nil?
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :right)
      elsif @strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :right)
      end
    end

    def page_up
      if @strategy == SCROLL_STRATEGY_UIAUTOMATOR || @strategy.nil?
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :up)
      elsif @strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :up)
      end
    end

    def page_left
      if @strategy == SCROLL_STRATEGY_UIAUTOMATOR || @strategy.nil?
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :left)
      elsif @strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :left)
      end
    end


    def fling_down
      if @strategy == SCROLL_STRATEGY_UIAUTOMATOR || @strategy.nil?
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_FLING, :down)
      elsif @strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_FLING, :down)
      end
    end

    def fling_right
      if @strategy == SCROLL_STRATEGY_UIAUTOMATOR || @strategy.nil?
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_FLING, :right)
      elsif @strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_FLING, :right)
      end
    end

    def fling_up
      if @strategy == SCROLL_STRATEGY_UIAUTOMATOR || @strategy.nil?
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_FLING, :up)
      elsif @strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_FLING, :up)
      end
    end

    def fling_left
      if @strategy == SCROLL_STRATEGY_UIAUTOMATOR || @strategy.nil?
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_FLING, :left)
      elsif @strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_FLING, :left)
      end
    end


    private

    def default_deadzone!
      @deadzone = {} if @deadzone.nil?
      if @deadzone[:top].nil?
        @deadzone[:top] = 1
      else
        @deadzone[:top] = @deadzone[:top].to_i
      end
      if @deadzone[:bottom].nil?
        @deadzone[:bottom] = 1
      else
        @deadzone[:bottom] = @deadzone[:bottom].to_i
      end
      if @deadzone[:right].nil?
        @deadzone[:right] = 1
      else
        @deadzone[:right] = @deadzone[:right].to_i
      end
      if @deadzone[:left].nil?
        @deadzone[:left] = 1
      else
        @deadzone[:left] = @deadzone[:left].to_i
      end
    end

    def is_aligned?(with, element)
      align_bounds = @locator.bounds(force_cache_element: element)
      case with
      when :top
        @align_offset = align_bounds.top_left.y - @bounds.top_left.y + @deadzone[:top]
      when :bottom
        @align_offset = @bounds.bottom_right.y - @deadzone[:bottom] - align_bounds.bottom_right.y
      when :right
        @align_offset = @bounds.bottom_right.x - @deadzone[:right] - align_bounds.bottom_right.x
      when :left
        @align_offset = align_bounds.top_left.x - @bounds.top_left.x + @deadzone[:left]
      else
        raise "Unsupported align with option: #{with}"
      end
      @align_offset < SCROLL_ALIGNMENT_THRESHOLD
    end
  end
end