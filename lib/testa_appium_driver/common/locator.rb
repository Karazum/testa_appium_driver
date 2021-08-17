require_relative 'locator/scroll_actions'


module TestaAppiumDriver
  #noinspection RubyTooManyInstanceVariablesInspection,RubyTooManyMethodsInspection
  class Locator
    include Helpers

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
    # @param [TestaAppiumDriver::Driver, TestaAppiumDriver::Locator, Selenium::WebDriver::Element] from_element from which element to execute the find_element
    # @param [Hash] params selectors and params for locator
    def initialize(driver, from_element, params = {})
      # @type [TestaAppiumDriver::Driver]
      @driver = driver

      params, selectors = extract_selectors_from_params(params)

      single = params[:single]

      @single = single

      @xpath_selector = hash_to_xpath(@driver.device, selectors, single)

      @from_element = from_element
      @default_find_strategy = params[:default_find_strategy]
      @default_scroll_strategy = params[:default_scroll_strategy]
      @strategy_reason = nil

      # @type [Boolean] used to determine if last selector was one of siblings or children. Only in those selectors we can reliably use xpath array [instance] selector
      @last_selector_adjacent = false

      init(params, selectors, single)
    end


    # method missing is used to fetch the element before executing additional commands like click, send_key, count
    def method_missing(method, *args, &block)
      execute.send(method, *args, &block)
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
    def wait_until_exists(timeout = @driver.get_timeouts["implicit"] / 1000)
      start_time = Time.now.to_f
      until exists?
        raise "wait until exists timeout exceeded" if start_time + timeout > Time.now.to_f
        sleep EXISTS_WAIT
      end
      self
    end


    # @param [Integer] timeout in seconds
    # @return [TestaAppiumDriver::Locator]
    def wait_while_exists(timeout = @driver.get_timeouts["implicit"] / 1000)
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

      if (@strategy.nil? && !@last_selector_adjacent) || @strategy == FIND_STRATEGY_UIAUTOMATOR
        @strategy = FIND_STRATEGY_UIAUTOMATOR
        @ui_selector = "#{@ui_selector}.instance(#{instance})"
      else
        from_element = self.execute[instance]
        params = {}.merge({single: true, scrollable_locator: @scrollable_locator})
        Locator.new(@driver, from_element, params)
      end
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
          uiautomator: defined?(self.ui_selector) ? ui_selector : nil,
          xpath: @xpath_selector,
          scrollable: @scrollable_locator.nil? ? nil : @scrollable_locator.to_s,
          scroll_orientation: @scroll_orientation
      }
    end

    def to_s
      JSON.dump(as_json)
    end

    def to_ary
      [self.to_s]
    end


    # @return [TestaAppiumDriver::Locator]
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


    def first_and_last_leaf
      @driver.first_and_last_leaf(execute)
    end


    def tap
      click
    end

    def click
      perform_driver_method(:click)
    end

    def send_key(*args)
      perform_driver_method(:send_keys, *args)
    end

    def clear
      perform_driver_method(:clear)
    end


    # Return parent element
    # @return [TestaAppiumDriver::Locator]
    def parent
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "parent") if @strategy != FIND_STRATEGY_XPATH
      raise "Cannot add parent selector to a retrieved instance of a class array" if @xpath_selector == "//" && !@from_element.nil?

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "parent"
      @xpath_selector += "/.."
      self
    end

    # Return all children elements
    # @return [TestaAppiumDriver::Locator]
    def children
      raise "Cannot add children selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "children") if @strategy != FIND_STRATEGY_XPATH

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "children"
      @xpath_selector += "/*"
      @single = false
      @last_selector_adjacent = true
      self
    end


    # Return first child element
    # @return [TestaAppiumDriver::Locator]
    def child
      raise "Cannot add children selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "child") if @strategy != FIND_STRATEGY_XPATH

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "child"
      @xpath_selector += "/*[1]"
      @single = true
      self
    end


    # @return [TestaAppiumDriver::Locator]
    def siblings
      raise "Cannot add siblings selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "siblings") if @strategy != FIND_STRATEGY_XPATH
      raise "Cannot add siblings selector to a retrieved instance of a class array" if @xpath_selector == "//" && !@from_element.nil?

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "siblings"
      @xpath_selector += "/../*[not(@index=\"#{index}\")]"
      @single = false
      @last_selector_adjacent = true
      self
    end

    # @return [TestaAppiumDriver::Locator]
    def preceding_siblings
      raise "Cannot add preceding_siblings selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "preceding_siblings") if @strategy != FIND_STRATEGY_XPATH
      raise "Cannot add preceding_siblings selector to a retrieved instance of a class array" if @xpath_selector == "//" && !@from_element.nil?

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "preceding_siblings"
      @xpath_selector += "/../*[position() < #{index + 1}]" # position() starts from 1
      @single = false
      @last_selector_adjacent = true
      self
    end

    # @return [TestaAppiumDriver::Locator]
    def preceding_sibling
      raise "Cannot add preceding_sibling selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "preceding_sibling") if @strategy != FIND_STRATEGY_XPATH
      raise "Cannot add preceding siblings selector to a retrieved instance of a class array" if @xpath_selector == "//" && !@from_element.nil?

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "preceding_sibling"
      i = index
      @single = true
      return nil if i == 0
      @xpath_selector += "/../*[@index=\"#{i - 1}\"]"
      @last_selector_adjacent = true
      self
    end


    # @return [TestaAppiumDriver::Locator]
    def following_siblings
      raise "Cannot add following_siblings selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "following_siblings") if @strategy != FIND_STRATEGY_XPATH
      raise "Cannot add following_siblings selector to a retrieved instance of a class array" if @xpath_selector == "//" && !@from_element.nil?

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "following_siblings"
      @xpath_selector += "/../*[position() > #{index + 1}]" # position() starts from 1
      @single = false
      @last_selector_adjacent = true
      self
    end

    # @return [TestaAppiumDriver::Locator]
    def following_sibling
      raise "Cannot add following_sibling selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "following_sibling") if @strategy != FIND_STRATEGY_XPATH
      raise "Cannot add following_sibling selector to a retrieved instance of a class array" if @xpath_selector == "//" && !@from_element.nil?

      @strategy = FIND_STRATEGY_XPATH
      @strategy_reason = "following_sibling"
      i = index
      @single = true
      return nil if i == 0
      @xpath_selector += "/../*[@index=\"#{i + 1}\"]"
      @last_selector_adjacent = true
      self
    end


    private

    #noinspection RubyNilAnalysis
    def perform_driver_method(name, *args)
      elements = execute
      if elements.kind_of?(Array)
        elements.map { |e| e.send(name, *args) }
      else
        elements.send(name, *args)
      end
    end

    def add_xpath_child_selectors(selectors, single)
      @single = false unless single # switching from single result to multiple
      @xpath_selector += hash_to_xpath(@driver.device, selectors, single)
      self
    end
  end

end