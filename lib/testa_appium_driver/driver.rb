# frozen_string_literal: true

require_relative 'common/bounds'
require_relative 'common/exceptions/strategy_mix_exception'

module TestaAppiumDriver
  class Driver
    attr_accessor :driver

    # custom options
    # - default_strategy: default strategy to be used for finding elements. Available strategies :uiautomator or :xpath
    def initialize(opts = {})
      @testa_opts = opts[:testa_appium_driver]
      handle_testa_opts

      core = Appium::Core.for(opts)
      extend_for(core.device, core.automation_name)

      @driver = core.start_driver
      invalidate_cache!

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
      @wait_for_idle_timeout = @driver.settings.get["waitForIdleTimeout"]
      @driver.update_settings({ waitForIdleTimeout: 0 })
    end

    def enable_wait_for_idle
      raise "Wait for idle is not disabled" if @wait_for_idle_timeout.nil?
      @driver.update_settings({ waitForIdleTimeout: @wait_for_idle_timeout })
    end

    def current_package
      @driver.current_package
    end

    def window_size(*args)
      @driver.window_size(*args)
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
          ::Appium::Ios::Xcuitest::Bridge.for(self)
        else
          raise "Testa appium driver not supported for #{automation_name} automation"
        end
      else
        raise "Unknown device #{device}, should be either android, ios or tvos"
      end
    end


    def handle_testa_opts
      if @testa_opts[:default_find_strategy].nil?
        @default_find_strategy = DEFAULT_FIND_STRATEGY
      else
        case @testa_opts[:default_find_strategy].to_sym
        when :uiautomator, :xpath
          @default_find_strategy = @testa_opts[:default_find_strategy].to_sym
        else
          raise "Default find strategy #{@testa_opts[:default_find_strategy]} not supported"
        end
      end


      if @testa_opts[:default_scroll_strategy].nil?
        @default_scroll_strategy = DEFAULT_SCROLL_STRATEGY
      else
        case @testa_opts[:default_scroll_strategy].to_sym
        when :w3c, :uiautomator
          @default_scroll_strategy = @testa_opts[:default_scroll_strategy].to_sym
        else
          raise "Default scroll strategy #{@testa_opts[:default_scroll_strategy]} not supported"
        end
      end


    end

  end

end
