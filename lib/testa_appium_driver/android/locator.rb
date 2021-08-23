require_relative 'locator/attributes'

module TestaAppiumDriver
  #noinspection RubyTooManyInstanceVariablesInspection
  class Locator
    attr_accessor :closing_parenthesis
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

        if !params[:top].nil? || !params[:bottom].nil? || !params[:right].nil? || !params[:left].nil?
          @scroll_deadzone = {}
          @scroll_deadzone[:top] = params[:top].to_f unless params[:top].nil?
          @scroll_deadzone[:bottom] = params[:bottom].to_f unless params[:bottom].nil?
          @scroll_deadzone[:right] = params[:right].to_f unless params[:right].nil?
          @scroll_deadzone[:left] = params[:left].to_f unless params[:left].nil?
        end

        params[:scrollable_locator] = self.dup
      end

      @scrollable_locator = params[:scrollable_locator] if params[:scrollable_locator]
    end


    # resolve selector which will be used for finding element
    def strategy_and_selector
      if @can_use_id_strategy
        return FIND_STRATEGY_ID, @can_use_id_strategy
      end
      if (@strategy.nil? && @default_find_strategy == FIND_STRATEGY_UIAUTOMATOR) || @strategy == FIND_STRATEGY_UIAUTOMATOR
        [FIND_STRATEGY_UIAUTOMATOR, ui_selector]
      elsif (@strategy.nil? && @default_find_strategy == FIND_STRATEGY_XPATH) || @strategy == FIND_STRATEGY_XPATH
        [FIND_STRATEGY_XPATH, @xpath_selector]
      end
    end


    # @param [Boolean] include_semicolon should the semicolon be included at the end
    # @return ui_selector for uiautomator find strategy
    def ui_selector(include_semicolon = true)
      @ui_selector + ")" * @closing_parenthesis + (include_semicolon ? ";" : "");
    end

    def ui_selector=(value)
      @ui_selector = value
    end




    # @return [TestaAppiumDriver::Locator]
    def from_parent(selectors = {})
      raise "Cannot add from_parent selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_UIAUTOMATOR, "from_parent") if @strategy != FIND_STRATEGY_UIAUTOMATOR

      locator = self.dup
      locator.strategy = FIND_STRATEGY_UIAUTOMATOR
      locator.strategy_reason = "from_parent"
      locator.closing_parenthesis += 1
      locator.ui_selector = "#{locator.ui_selector}.fromParent(#{hash_to_uiautomator(selectors)}"
      locator
    end


    # @return [Locator] new child locator element
    def add_child_selector(params)
      params, selectors = extract_selectors_from_params(params)
      single = params[:single]
      raise "Cannot add child selector to Array" if single && !@single

      locator = self.dup
      locator.can_use_id_strategy = false
      if (@strategy.nil? && !single) || @strategy == FIND_STRATEGY_XPATH
        locator.strategy = FIND_STRATEGY_XPATH
        locator.strategy_reason = "multiple child selector"
        add_xpath_child_selectors(locator, selectors, single)
      elsif @strategy == FIND_STRATEGY_UIAUTOMATOR
        locator = add_uiautomator_child_selector(locator, selectors, single)
      else
        # both paths are valid
        add_xpath_child_selectors(locator, selectors, single)
        locator = add_uiautomator_child_selector(locator, selectors, single)
      end

      if is_scrollable_selector?(selectors, single)
        locator.scrollable_locator = self
        if selectors[:class] == "android.widget.HorizontalScrollView"
          locator.scrollable_locator.scroll_orientation = :horizontal
        else
          locator.scrollable_locator.scroll_orientation = :vertical
        end
      end

      locator.last_selector_adjacent = false
      locator
    end


    private
    def add_uiautomator_child_selector(locator, selectors, single)
      if locator.single && !single
        # current locator stays single, the child locator looks for multiple
        params = selectors.merge({single: single, scrollable_locator: locator.scrollable_locator})
        params[:default_find_strategy] = locator.default_find_strategy
        params[:default_scroll_strategy] = locator.default_scroll_strategy
        Locator.new(@driver, self, params)
      else
        locator.single = true
        locator.ui_selector = "#{locator.ui_selector(false)}.childSelector(#{hash_to_uiautomator(selectors, single)})"
        locator
      end
    end
  end
end