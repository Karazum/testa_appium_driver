# frozen_string_literal: true

require 'em/pure_ruby'
require 'appium_lib_core'

require_relative 'common/bounds'
require_relative 'common/exceptions/strategy_mix_exception'
require_relative 'common/helpers'
require_relative 'common/locator'
require_relative 'common/scroll_actions'
require_relative 'common/selenium_element'

module TestaAppiumDriver
  class Driver
    include Helpers

    # @return [::Appium::Core::Base::Driver] the ruby_lib_core appium driver
    attr_accessor :driver

    # @return [String] iOS or Android
    attr_reader :device

    # @return [String] driver automation name (uiautomator2 or xcuitest)
    attr_reader :automation_name

    # custom options
    # - default_find_strategy: default strategy to be used for finding elements. Available strategies :uiautomator or :xpath
    # - default_scroll_strategy: default strategy to be used for scrolling. Available strategies: :uiautomator(android only), :w3c
    def initialize(opts = {})
      @testa_opts = opts[:testa_appium_driver] || {}


      core = Appium::Core.for(opts)
      extend_for(core.device, core.automation_name)
      @device = core.device
      @automation_name = core.automation_name

      handle_testa_opts

      @driver = core.start_driver
      invalidate_cache


      Selenium::WebDriver::Element.set_driver(self, opts[:caps][:udid])
    end


    # invalidates current find_element cache
    def invalidate_cache
      @cache = {
          strategy: nil,
          selector: nil,
          element: nil,
          from_element: nil,
          time: Time.at(0)
      }
    end




    # Executes the find_element with the resolved locator strategy and selector. Find_element might be skipped if cache is hit.
    # Cache stores last executed find_element with given selector, strategy and from_element. If given values are the same within
    # last 5 seconds element is retrieved from cache.
    # @param [TestaAppiumDriver::Locator, TestaAppiumDriver::Driver] from_element element from which start the search
    # @param [String] selector resolved string of a [TestaAppiumDriver::Locator] selector xpath for xpath strategy, java UiSelectors for uiautomator or id for ID strategy
    # @param [Boolean] single fetch single or multiple results
    # @param [Symbol, nil] strategy [TestaAppiumDriver::FIND_STRATEGY_UIAUTOMATOR], [TestaAppiumDriver::FIND_STRATEGY_XPATH] or [TestaAppiumDriver::FIND_STRATEGY_ID]
    # @param [Symbol] default_strategy if strategy is not enforced, default can be used
    # @param [Boolean] skip_cache to skip checking and storing cache
    # @return [Selenium::WebDriver::Element, Array] element is returned if single is true, array otherwise
    def execute(from_element, selector, single, strategy, default_strategy, skip_cache = false)

      # if user wants to wait for element to exist, he can use wait_until_present
      disable_wait_for_idle


      # if not restricted to a strategy, use the default one
      strategy = default_strategy if strategy.nil?

      # resolve from_element unique id, so that we can cache it properly
      from_element_id = from_element.kind_of?(TestaAppiumDriver::Locator) ? from_element.strategy_and_selector[1] : nil

      puts "Executing #{from_element_id ? "from #{from_element.strategy}: #{from_element.strategy_and_selector} => " : ""}#{strategy}: #{selector}"
      begin
        if @cache[:selector] != selector || # cache miss, selector is different
            @cache[:time] + 5 <= Time.now || # cache miss, older than 5 seconds
            @cache[:strategy] != strategy || # cache miss, different find strategy
            @cache[:from_element_id] != from_element_id || # cache miss, search is started from different element
            skip_cache # cache is skipped

          if single
            execute_result = from_element.find_element("#{strategy}": selector)
          else
            execute_result = from_element.find_elements("#{strategy}": selector)
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
    # after the method is executed, find element cache is invalidated
    def method_missing(method, *args, &block)
      @driver.send(method, *args, &block)
      invalidate_cache
    end

    # disables implicit wait
    def disable_implicit_wait
      @implicit_wait_ms = @driver.get_timeouts["implicit"]
      @driver.manage.timeouts.implicit_wait = 0
    end

    # enables implicit wait, can be called only after disabling implicit wait
    def enable_implicit_wait
      raise "Implicit wait is not disabled" if @implicit_wait_ms.nil?
      # get_timeouts always returns in milliseconds, but we should set in seconds
      @driver.manage.timeouts.implicit_wait = @implicit_wait_ms / 1000
    end

    # disables wait for idle, only executed for android devices
    def disable_wait_for_idle
      if @device == :android
        @wait_for_idle_timeout = @driver.settings.get["waitForIdleTimeout"]
        @driver.update_settings({waitForIdleTimeout: 0})
      end
    end

    # enables wait for idle, only executed for android devices
    def enable_wait_for_idle
      if @device == :android
        raise "Wait for idle is not disabled" if @wait_for_idle_timeout.nil?
        @driver.update_settings({waitForIdleTimeout: @wait_for_idle_timeout})
      end
    end


    # @@return [String] current package under test
    def current_package
      @driver.current_package
    end


    def window_size
      @driver.window_size
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


    # @return [Array<Selenium::WebDriver::Element] array of 2 elements, the first element without children and the last element without children in the current page
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
