require_relative 'scroll_actions/json_wire_scroll_actions'
require_relative 'scroll_actions/w3c_scroll_actions'
require_relative 'scroll_actions/uiautomator_scroll_actions'

module TestaAppiumDriver
  #noinspection RubyResolve,RubyTooManyInstanceVariablesInspection
  class ScrollActions

    def initialize(scrollable, params = {})
      @scrollable = scrollable
      @locator = params[:locator]
      @deadzone = params[:deadzone]
      @direction = params[:direction]
      @max_scrolls = params[:max_scrolls]
      @default_scroll_strategy = params[:default_scroll_strategy]
      @driver = @locator.driver

      @raise = params[:raise]

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

    # @return [Array]
    def each(skip_scroll_to_start,  &block)
      w3c_each(skip_scroll_to_start,  &block)
    end

    def resolve_strategy
      if @strategy.nil?
        @default_scroll_strategy
      else
        @strategy
      end
    end


    def scroll_to
      if @locator.strategy != FIND_STRATEGY_XPATH && resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_scroll_to
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_scroll_to(nil)
      end
    end

    def scroll_down_to
      if resolve_strategy == SCROLL_STRATEGY_W3C
        # we have direction enabled, uiautomator does not support direction specific element search
        w3c_scroll_to(:down)
      elsif resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        raise "scroll_down_to is not supported for uiautomator scroll strategy. Use scroll_to without deadzone"
      end
    end

    def scroll_up_to
      if resolve_strategy == SCROLL_STRATEGY_W3C
        # we have direction enabled, uiautomator does not support direction specific element search
        w3c_scroll_to(:up)
      elsif resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        raise "scroll_up_to is not supported for uiautomator scroll strategy. Use scroll_to without deadzone"
      end
    end

    def scroll_right_to
      if resolve_strategy == SCROLL_STRATEGY_W3C
        # we have direction enabled, uiautomator does not support direction specific element search
        w3c_scroll_to(:right)
      elsif resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        raise "scroll_right_to is not supported for uiautomator scroll strategy. Use scroll_to without deadzone"
      end
    end

    def scroll_left_to
      if resolve_strategy == SCROLL_STRATEGY_W3C
        # we have direction enabled, uiautomator does not support direction specific element search
        w3c_scroll_to(:left)
      elsif resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        raise "scroll_left_to is not supported for uiautomator scroll strategy. Use scroll_to without deadzone"
      end
    end

    def page_next
      if @scrollable.scroll_orientation == :vertical
        page_down
      else
        page_left
      end
    end

    def page_back
      if @scrollable.scroll_orientation == :vertical
        page_up
      else
        page_right
      end
    end


    def page_down
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :down)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :down)
      end
    end

    def page_right
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :right)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :right)
      end
    end

    def page_up
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :up)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :up)
      end
    end

    def page_left
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :left)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_SCROLL, :left)
      end
    end


    def scroll_to_start
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_scroll_to_start_or_end(:start)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_scroll_to_start_or_end(:start)
      end
    end

    def scroll_to_end
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_scroll_to_start_or_end(:end)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_scroll_to_start_or_end(:end)
      end
    end

    def fling_down
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_FLING, :down)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_FLING, :down)
      end
    end

    def fling_right
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_FLING, :right)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_FLING, :right)
      end
    end

    def fling_up
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_FLING, :up)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_FLING, :up)
      end
    end

    def fling_left
      if resolve_strategy == SCROLL_STRATEGY_UIAUTOMATOR
        uiautomator_page_or_fling(SCROLL_ACTION_TYPE_FLING, :left)
      elsif resolve_strategy == SCROLL_STRATEGY_W3C
        w3c_page_or_fling(SCROLL_ACTION_TYPE_FLING, :left)
      end
    end

    def drag_to(x, y)
      w3c_drag_to(x, y)
    end


    private
    def is_end_of_scroll?
      old_elements = @previous_elements
      @previous_elements = @scrollable.first_and_last_leaf
      old_elements == @previous_elements
    end


    def default_deadzone!
      @deadzone = {} if @deadzone.nil?
      if @deadzone[:top].nil?
        @deadzone[:top] = 1
      else
        @deadzone[:top] = @deadzone[:top].to_f
      end
      if @deadzone[:bottom].nil?
        @deadzone[:bottom] = 1
      else
        @deadzone[:bottom] = @deadzone[:bottom].to_f
      end
      if @deadzone[:right].nil?
        @deadzone[:right] = 1
      else
        @deadzone[:right] = @deadzone[:right].to_f
      end
      if @deadzone[:left].nil?
        @deadzone[:left] = 1
      else
        @deadzone[:left] = @deadzone[:left].to_f
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