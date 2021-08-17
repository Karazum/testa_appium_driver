require_relative 'locator/attributes'
require_relative 'scroll_actions'
require_relative 'locator/scroll_actions'

module TestaAppiumDriver
  #noinspection RubyTooManyInstanceVariablesInspection
  class Locator
    include Helpers
    include ClassSelectors

    attr_accessor :xpath_selector
    attr_accessor :single

    attr_accessor :driver
    attr_accessor :strategy

    attr_accessor :from_element
    attr_accessor :scroll_orientation
    attr_accessor :scroll_deadzone


    # locator parameters are:
    #   single: true or false
    #   scrollable_locator: [TestaAppiumDriver::Locator, nil] for scrolling if needed later
    #   default_find_strategy: default strategy if find element strategy is not enforced
    #   default_scroll_strategy: default strategy for scrolling if not enforced
    #
    # @param [TestaAppiumDriver::Driver] driver
    # @param [TestaAppiumDriver, Locator, Selenium::WebDriver::Element] from_element from which element to execute the find_element
    # @param [Hash] params selectors and params for locator
    def initialize(driver, from_element, params = {})
      params, selectors = extract_selectors_from_params(params)

      # @type [TestaAppiumDriver::Driver]
      @driver = driver
      single = params[:single]

      @single = single
      @closing_parenthesis = 0
      @ui_selector = hash_to_uiautomator(selectors, single)
      @xpath_selector = hash_to_xpath(selectors, single)

      @from_element = from_element
      @default_find_strategy = params[:default_find_strategy]
      @default_scroll_strategy = params[:default_scroll_strategy]
      @strategy_reason = nil

      if is_scrollable_selector?(selectors, single)
        if selectors[:class] == "android.widget.HorizontalScrollView"
          @scroll_orientation = :horizontal
        else
          @scroll_orientation = :vertical
        end
        params[:scrollable_locator] = self.dup
      end

      @scrollable_locator = params[:scrollable_locator]
    end



    # method missing is used to fetch the element before executing additional commands like click, send_key, count
    def method_missing(method, *args, &block)
      execute.send(method, *args, &block)
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



    # @param [Boolean] skip_cache if true it will skip cache check and store
    # @param [Selenium::WebDriver::Element] force_cache_element, for internal use where we have already the element, and want to execute custom locator methods on it
    # @return [Selenium::WebDriver::Element, Array]
    def execute(skip_cache: false, force_cache_element: nil)
      return force_cache_element unless force_cache_element.nil?
      @driver.execute(@from_element, selector, @single, @strategy, @default_find_strategy, skip_cache)
    end




    # @param [Integer] timeout in seconds
    # @return [TestaAppiumDriver::Locator]
    def wait_until_exists(timeout = @driver.get_timeouts["implicit"]/1000)
      start_time = Time.now.to_f
      until exists?
        raise "wait until exists timeout exceeded" if start_time + timeout > Time.now.to_f
        sleep EXISTS_WAIT
      end
      self
    end



    # @param [Integer] timeout in seconds
    # @return [TestaAppiumDriver::Locator]
    def wait_while_exists(timeout = @driver.get_timeouts["implicit"]/1000)
      start_time = Time.now.to_f
      while exists?
        raise "wait until exists timeout exceeded" if start_time + timeout > Time.now.to_f
        sleep EXISTS_WAIT
      end
      self
    end




    # all timeouts are disabled before check, and enabled after check
    # @return [boolean] true if it exists in the page regardless if visible or not
    def exists?
      @driver.disable_wait_for_idle
      @driver.disable_implicit_wait
      found = true
      begin
        execute(skip_cache: true)
      rescue StandardError
        found = false
      end
      @driver.enable_implicit_wait
      @driver.enable_wait_for_idle
      found
    end




    def [](instance)
      raise "Cannot add index selector to non-Array" if @single
      @single = true

      @ui_selector = "#{@ui_selector}.instance(#{instance})"
      @xpath_selector = "#{@ui_selector}[#{instance.to_i + 1}]"
      self
    end



    # @param [TestaAppiumDriver::Locator, Selenium::WebDriver::Element, Array] other
    #noinspection RubyNilAnalysis,RubyUnnecessaryReturnStatement
    def ==(other)
      elements = execute
      other = other.execute if other.kind_of?(TestaAppiumDriver::Locator)

      if elements.kind_of?(Array)
          return false unless other.kind_of?(Array)
          return false if other.count != elements.count
          return (elements - other).empty?
      else
        return false if other.kind_of?(Array)
        return elements == other
      end
    end

    def as_json
      {
        strategy: @strategy,
        default_strategy: @default_find_strategy,
        single: @single,
        context: @from_element.nil? ? nil : @from_element.to_s,
        uiautomator: ui_selector,
        xpath: @xpath_selector,
        scrollable: @scrollable_locator.nil? ? nil : @scrollable_locator.to_s
      }
    end
    def to_s
      JSON.dump(as_json)
    end

    def to_ary
      [self.to_s]
    end

    def as_scrollable(orientation: :vertical, top: nil, bottom: nil, right: nil, left: nil)
      @scroll_orientation = orientation
      if !top.nil? || !bottom.nil? || !right.nil? || !left.nil?
        @scroll_deadzone = {}
        @scroll_deadzone[:top] = top.to_f unless top.nil?
        @scroll_deadzone[:bottom] = bottom.to_f unless bottom.nil?
        @scroll_deadzone[:right] = right.to_f unless right.nil?
        @scroll_deadzone[:left] = left.to_f unless left.nil?
      end
      @scrollable_locator = self.dup
      self
    end

    def parent
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "parent") if @strategy == FIND_STRATEGY_UIAUTOMATOR

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "parent"
      @xpath_selector += "/.."
      self
    end

    def children
      raise "Cannot add children selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "children") if @strategy == FIND_STRATEGY_UIAUTOMATOR

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "children"
      @single = false
      @xpath_selector += "/*"
      self
    end

    def from_parent(selectors = {})
      raise "Cannot add from_parent selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_UIAUTOMATOR, "from_parent") if @strategy == FIND_STRATEGY_XPATH

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
      end

      self
    end



    def first_and_last_leaf
      @driver.first_and_last_leaf(execute)
    end

    private
    def add_xpath_child_selectors(selectors, single)
      @single = false unless single # switching from single result to multiple
      @xpath_selector += hash_to_xpath(selectors, single)
      self
    end

    def add_uiautomator_child_selector(selectors, single)
      if @single && !single
        # current locator stays single, the child locator looks for multiple
        params = selectors.merge({ single: single, scrollable_locator: @scrollable_locator })
        Locator.new(@driver, self, params)
      else
        @single = true
        @ui_selector = "#{@ui_selector}.childSelector(#{hash_to_uiautomator(selectors, single)})"
        self
      end
    end

  end
end