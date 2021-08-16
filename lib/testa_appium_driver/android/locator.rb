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


    # @param [TestaAppiumDriver::Driver] driver
    # @param [Hash] params
    # @param [TestaAppiumDriver, Locator, Selenium::WebDriver::Element] from_element, from which element to execute the find_element
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
      @default_strategy = params[:default_strategy]
      @strategy_reason = nil

      if is_scrollable_selector(selectors, single)
        params[:scrollable_locator] = self.dup
      end


      @scrollable_locator = params[:scrollable_locator]
    end

    # method missing is used to fetch the element before executing additional commands like click, send_key, count
    def method_missing(method, *args, &block)
      execute.send(method, *args, &block)
    end

    def selector
      if (@strategy.nil? && @default_strategy == FIND_STRATEGY_UIAUTOMATOR) || @strategy == FIND_STRATEGY_UIAUTOMATOR
        ui_selector
      elsif (@strategy.nil? && @default_strategy == FIND_STRATEGY_XPATH) || @strategy == FIND_STRATEGY_XPATH
        @xpath_selector
      end
    end

    def ui_selector(include_semicolon = true)
      @ui_selector + ")" * @closing_parenthesis + (include_semicolon ? ";" : "");
    end

    # @param [Boolean] skip_cache if true it will skip cache check and store
    # @param [Boolean] force_cache_element, for internal use where we have already the element, and want to execute custom locator methods on it
    # @return Selenium::WebDriver::Element
    def execute(skip_cache: false, force_cache_element: nil)
      return force_cache_element unless force_cache_element.nil?
      @driver.execute(@from_element, selector, @single, @strategy, @default_strategy, skip_cache)
    end


    def wait_until_exists(timeout_ms = @driver.get_timeouts["implicit"])
      start_time = Time.now.to_f
      until exists?
        raise "wait until exists timeout exceeded" if start_time + timeout_ms > Time.now.to_f
        sleep EXISTS_WAIT
      end
      @locator
    end

    def wait_while_exists(timeout_ms = @driver.get_timeouts["implicit"])
      start_time = Time.now.to_f
      while exists?
        raise "wait until exists timeout exceeded" if start_time + timeout_ms > Time.now.to_f
        sleep EXISTS_WAIT
      end
      @locator
    end


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

    def ==
      raise "Method not implemented yet, waiting for: https://github.com/appium/appium-uiautomator2-server/issues/438"
      #raise "Cannot compare arrays" unless @single
      #ele = execute
    end

    def as_scrollable
      @scroll_container = self.dup
    end

    def parent
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "parent") if @strategy == FIND_STRATEGY_UIAUTOMATOR

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "parent"
      @xpath_selector += "/.."
    end

    def children
      raise "Cannot add children selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "children") if @strategy == FIND_STRATEGY_UIAUTOMATOR

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "children"
      @single = false
      @xpath_selector += "/*"
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
    def add_child_selector(selectors, single = true)
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

      if is_scrollable_selector(selectors, single)
        @scrollable_locator = self.dup
      end

      self
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