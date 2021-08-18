require_relative 'locator/attributes'

module TestaAppiumDriver
  #noinspection RubyTooManyInstanceVariablesInspection
  class Locator
    include ClassSelectors

    def init(params, selectors, single)
      @closing_parenthesis = 0
      @ui_selector = hash_to_uiautomator(selectors, single)

      if is_scrollable_selector?(selectors, single)
        if selectors[:class] == "android.widget.HorizontalScrollView"
          @scroll_orientation = :horizontal
        else
          @scroll_orientation = :vertical
        end
        params[:scrollable_locator] = self.dup
      end

      @scrollable_locator = params[:scrollable_locator] if params[:scrollable_locator]
    end


    # resolve selector which will be used for finding element
    def selector
      if (@strategy.nil? && @default_find_strategy == FIND_STRATEGY_UIAUTOMATOR) || @strategy == FIND_STRATEGY_UIAUTOMATOR
        ui_selector
      elsif (@strategy.nil? && @default_find_strategy == FIND_STRATEGY_XPATH) || @strategy == FIND_STRATEGY_XPATH
        @xpath_selector
      end
    end



    # @param [Boolean] include_semicolon should the semicolon be included at the end
    # @return ui_selector for uiautomator find strategy
    def ui_selector(include_semicolon = true)
      @ui_selector + ")" * @closing_parenthesis + (include_semicolon ? ";" : "");
    end




    # @return [TestaAppiumDriver::Locator]
    def from_parent(selectors = {})
      raise "Cannot add from_parent selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_UIAUTOMATOR, "from_parent") if @strategy != FIND_STRATEGY_UIAUTOMATOR

      @strategy = FIND_STRATEGY_UIAUTOMATOR
      @strategy_reason = "from_parent"
      @closing_parenthesis += 1
      @ui_selector = "#{@ui_selector}.fromParent(#{hash_to_uiautomator(selectors)}"
      self
    end


    # @return [Locator] existing locator element
    def add_child_selector(params)
      params, selectors = extract_selectors_from_params(params)
      single = params[:single]
      raise "Cannot add child selector to Array" if single && !@single

      if (@strategy.nil? && !single) || @strategy == FIND_STRATEGY_XPATH
        @strategy = FIND_STRATEGY_XPATH
        @strategy_reason = "multiple child selector"
        add_xpath_child_selectors(selectors, single)
      elsif @strategy == FIND_STRATEGY_UIAUTOMATOR
        add_uiautomator_child_selector(selectors, single)
      else
        # both paths are valid
        add_xpath_child_selectors(selectors, single)
        add_uiautomator_child_selector(selectors, single)
      end

      if is_scrollable_selector?(selectors, single)
        @scrollable_locator = self.dup
        if selectors[:class] == "android.widget.HorizontalScrollView"
          @scrollable_locator.scroll_orientation = :horizontal
        else
          @scrollable_locator.scroll_orientation = :vertical
        end
      end

      @last_selector_adjacent = false
      self
    end


    private
    def add_uiautomator_child_selector(selectors, single)
      if @single && !single
        # current locator stays single, the child locator looks for multiple
        params = selectors.merge({single: single, scrollable_locator: @scrollable_locator})
        params[:default_find_strategy] = @default_find_strategy
        params[:default_scroll_strategy] = @default_scroll_strategy
        Locator.new(@driver, self, params)
      else
        @single = true
        @ui_selector = "#{@ui_selector}.childSelector(#{hash_to_uiautomator(selectors, single)})"
        self
      end
    end
  end
end