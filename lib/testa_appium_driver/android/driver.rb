require_relative 'helpers'
require_relative 'class_selectors'
require_relative 'locator'
require_relative 'scroll_actions'

module TestaAppiumDriver
  class Driver
    include ClassSelectors

    #noinspection RubyScope
    # @param [TestaAppiumDriver::Locator, TestaAppiumDriver::Driver] from_element element from which start the search
    # @param [String] selector resolved string of a [TestaAppiumDriver::Locator] selector xpath for xpath strategy, java UiSelectors for uiautomator
    # @param [Boolean] single fetch single or multiple results
    # @param [Symbol, nil] strategy [TestaAppiumDriver:FIND_STRATEGY_UIAUTOMATOR] or [FIND_STRATEGY_XPATH]
    # @param [Symbol] default_strategy if strategy is not enforced, default can be used
    # @param [Boolean] skip_cache to skip checking and storing cache
    # @return [Selenium::WebDriver::Element, Array] element is returned if single is true, array otherwise
    def execute(from_element, selector, single, strategy, default_strategy, skip_cache = false)

      # if user wants to wait for element to exist, he can use wait_until_present
      disable_wait_for_idle

      # if we are not restricted to a strategy, use the default one
      strategy = default_strategy if strategy.nil?

      # resolve from_element unique id, so that we can cache it properly
      from_element_id = from_element.kind_of?(TestaAppiumDriver::Locator) ? from_element.selector : nil

      puts "Executing #{from_element_id ? "from #{from_element.strategy}: #{from_element.selector} => " : ""}#{strategy}: #{selector}"
      begin
        if @cache[:selector] != selector || # cache miss, selector is different
            @cache[:time] + 5 <= Time.now || # cache miss, older than 5 seconds
            @cache[:strategy] != strategy || # cache miss, different find strategy
            @cache[:from_element_id] != from_element_id || # cache miss, search is started from different element
            skip_cache  # cache is skipped

          if strategy == FIND_STRATEGY_UIAUTOMATOR
            if single
              execute_result = from_element.find_element(uiautomator: selector)
            else
              execute_result = from_element.find_elements(uiautomator: selector)
            end

          elsif strategy == FIND_STRATEGY_XPATH
            if single
              execute_result = from_element.find_element(xpath: selector)
            else
              execute_result = from_element.find_elements(xpath: selector)
            end
          else
            raise "Unknown find_element strategy"
          end

          unless skip_cache
            @cache[:selector] = selector
            @cache[:strategy] = strategy
            @cache[:time] = Time.now
            @cache[:from_element_id] = from_element_id
            @cache[:element] = execute_result
          end
        else
          # this is a cache hit, use the element from cache
          execute_result = @cache[:element]
          puts "Using cache from #{@cache[:time].strftime("%H:%M:%S.%L")}, strategy: #{@cache[:strategy]}"
        end
      rescue => e
        raise e
      ensure
        enable_wait_for_idle
      end

      execute_result
    end
  end

end