require_relative 'locator/attributes'

module TestaAppiumDriver
  class Locator
    include TypeSelectors
    attr_accessor :class_chain_selector

    def init(params, selectors, single)
      if is_scrollable_selector?(selectors, single)
        @scroll_orientation = :vertical

        if !params[:top].nil? || !params[:bottom].nil? || !params[:right].nil? || !params[:left].nil?
          @scroll_deadzone = {}
          @scroll_deadzone[:top] = params[:top].to_f unless params[:top].nil?
          @scroll_deadzone[:bottom] = params[:bottom].to_f unless params[:bottom].nil?
          @scroll_deadzone[:right] = params[:right].to_f unless params[:right].nil?
          @scroll_deadzone[:left] = params[:left].to_f unless params[:left].nil?
        end

        params[:scrollable_locator] = self.dup
      end

      @class_chain_selector = hash_to_class_chain(selectors, single)


      @scrollable_locator = params[:scrollable_locator] if params[:scrollable_locator]
    end


    # @return [Array] returns 2 elements. The first is the resolved find element strategy and the second is the resolved selector
    def strategies_and_selectors
      ss = []
      if @can_use_id_strategy
        ss.push({"#{FIND_STRATEGY_NAME}": @can_use_id_strategy})
      end
      ss.push({"#{FIND_STRATEGY_CLASS_CHAIN}": @class_chain_selector}) if @strategy.nil? || @strategy == FIND_STRATEGY_CLASS_CHAIN
      ss.push({"#{FIND_STRATEGY_XPATH}": @xpath_selector}) if @strategy.nil? || @strategy == FIND_STRATEGY_XPATH
      ss.push({"#{FIND_STRATEGY_IMAGE}": @image_selector}) if @strategy == FIND_STRATEGY_IMAGE
      ss
    end



    # @return [Locator] new child locator element
    def add_child_selector(params)
      params, selectors = extract_selectors_from_params(params)
      single = params[:single]
      raise "Cannot add child selector to Array" if single && !@single

      locator = self.dup
      add_xpath_child_selectors(locator, selectors, single)
      if @strategy.nil? || @strategy == FIND_STRATEGY_CLASS_CHAIN
        add_class_chain_child_selectors(locator, selectors, single)
      end

      if is_scrollable_selector?(selectors, single)
        locator.scrollable_locator.scroll_orientation = :vertical
        locator.scrollable_locator = self.dup
      end

      locator.last_selector_adjacent = false
      locator
    end


    def add_class_chain_child_selectors(locator, selectors, single)
      locator.single = false unless single # switching from single result to multiple
      locator.class_chain_selector += "/" + hash_to_class_chain(selectors, single)
    end
  end
end