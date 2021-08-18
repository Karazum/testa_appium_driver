# frozen_string_literal: true

require_relative 'common/bounds'
require_relative 'common/exceptions/strategy_mix_exception'
require_relative 'common/helpers'
require_relative 'common/locator'
require_relative 'common/scroll_actions'

module TestaAppiumDriver
  class Driver
    attr_accessor :driver
    attr_reader :device
    attr_reader :automation_name

    # custom options
    # - default_strategy: default strategy to be used for finding elements. Available strategies :uiautomator or :xpath
    def initialize(opts = {})
      @testa_opts = opts[:testa_appium_driver] || {}



      core = Appium::Core.for(opts)
      extend_for(core.device, core.automation_name)
      @device = core.device
      @automation_name = core.automation_name

      handle_testa_opts

      @driver = core.start_driver
      invalidate_cache!



      extend_element_with_driver(opts[:caps][:udid])
    end


    def invalidate_cache!
      @cache = {
          strategy: nil,
          selector: nil,
          element: nil,
          from_element: nil,
          time: Time.at(0)
      }
    end

    #noinspection RubyClassVariableUsageInspection
    def extend_element_with_driver(udid)
      Selenium::WebDriver::Element.define_singleton_method(:set_driver) do |driver|
        udid = "unknown" if udid.nil?
        @@drivers ||={}
        @@drivers[udid] = driver
      end

      Selenium::WebDriver::Element.set_driver(self)
      Selenium::WebDriver::Element.define_method(:get_driver) do
        udid = self.instance_variable_get(:@bridge).instance_variable_get(:@capabilities).instance_variable_get(:@capabilities)["udid"]
        udid = "unknown" if udid.nil?
        @@drivers[udid]
      end
    end


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

      # if not restricted to a strategy, use the default one
      strategy = default_strategy if strategy.nil?

      # resolve from_element unique id, so that we can cache it properly
      from_element_id = from_element.kind_of?(TestaAppiumDriver::Locator) ? from_element.selector : nil

      puts "Executing #{from_element_id ? "from #{from_element.strategy}: #{from_element.selector} => " : ""}#{strategy}: #{selector}"
      begin
        if @cache[:selector] != selector || # cache miss, selector is different
            @cache[:time] + 5 <= Time.now || # cache miss, older than 5 seconds
            @cache[:strategy] != strategy || # cache miss, different find strategy
            @cache[:from_element_id] != from_element_id || # cache miss, search is started from different element
            skip_cache # cache is skipped

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


    # method missing is used to forward methods to the actual appium driver
    def method_missing(method, *args, &block)
      @driver.send(method, *args, &block)
    end

    def disable_implicit_wait
      @implicit_wait_ms = @driver.get_timeouts["implicit"]
      @driver.manage.timeouts.implicit_wait = 0
    end

    def enable_implicit_wait
      raise "Implicit wait is not disabled" if @implicit_wait_ms.nil?
      # get_timeouts always returns in milliseconds, but we should set in seconds
      @driver.manage.timeouts.implicit_wait = @implicit_wait_ms / 1000
    end

    def disable_wait_for_idle
      if @device == :android
        @wait_for_idle_timeout = @driver.settings.get["waitForIdleTimeout"]
        @driver.update_settings({waitForIdleTimeout: 0})
      end
    end

    def enable_wait_for_idle
      if @device == :android
        raise "Wait for idle is not disabled" if @wait_for_idle_timeout.nil?
        @driver.update_settings({waitForIdleTimeout: @wait_for_idle_timeout})
      end
    end

    def current_package
      @driver.current_package
    end

    def window_size(*args)
      @driver.window_size(*args)
    end

    def back
      @driver.back
    end


    def is_keyboard_shown?
      @driver.is_keyboard_shown
    end

    def hide_keyboard
      @driver.hide_keyboard
    end

    def press_keycode(code)
      @driver.press_keycode(code)
    end

    def long_press_keycode(code)
      @driver.long_press_keycode(code)
    end


    def first_and_last_leaf(from_element = @driver)
      disable_wait_for_idle
      disable_implicit_wait
      elements = from_element.find_elements(xpath: "//*[not(*)]")
      enable_implicit_wait
      enable_wait_for_idle
      return nil if elements.count == 0
      [elements[0], elements[-1]]
    end

    private
    def extend_for(device, automation_name)
      case device
      when :android
        case automation_name
        when :uiautomator2
          require_relative 'android/driver'
        else
          raise "Testa appium driver not supported for #{automation_name} automation"
        end
      when :ios, :tvos
        case automation_name
        when :xcuitest
          require_relative 'ios/driver'
        else
          raise "Testa appium driver not supported for #{automation_name} automation"
        end
      else
        raise "Unknown device #{device}, should be either android, ios or tvos"
      end
    end


  end

end
