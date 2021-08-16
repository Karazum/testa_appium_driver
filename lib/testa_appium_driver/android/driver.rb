require_relative 'helpers'
require_relative 'class_selectors'
require_relative 'locator'
require_relative 'scroll_actions'

module TestaAppiumDriver
  class Driver
    include ClassSelectors

    #noinspection RubyScope
    def execute(from_element, selector, single, strategy, default_strategy, skip_cache = false)
      disable_wait_for_idle

      strategy = default_strategy if strategy.nil?

      from_element_id = from_element.kind_of?(TestaAppiumDriver::Locator) ? from_element.selector : nil

      puts "Executing #{from_element_id ? "from #{from_element.strategy}: #{from_element.selector} => " : ""}#{strategy}: #{selector}"
      begin
        if @cache[:selector] != selector ||
            @cache[:time] + 5 <= Time.now ||
            @cache[:strategy] != strategy ||
            @cache[:from_element_id] != from_element_id ||
            skip_cache
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