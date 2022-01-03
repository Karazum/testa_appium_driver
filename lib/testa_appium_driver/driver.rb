# frozen_string_literal: true

#require 'em/pure_ruby'
#require 'appium_lib_core'

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

      @wait_for_idle_disabled = false
      @implicit_wait_disabled = false

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
    # @param [Boolean] single fetch single or multiple results
    # @param [Array<Hash>] strategies_and_selectors array of usable strategies and selectors
    # @param [Boolean] skip_cache to skip checking and storing cache
    # @return [Selenium::WebDriver::Element, Array] element is returned if single is true, array otherwise
    def execute(from_element, single, strategies_and_selectors, skip_cache = false, ignore_implicit_wait = false)

      # if user wants to wait for element to exist, he can use wait_until_present
      disable_wait_for_idle
      disable_implicit_wait
      start_time = Time.now.to_f
      ss_index = 0




      # resolve from_element unique id, so that we can cache it properly
      from_element_id = from_element.instance_of?(TestaAppiumDriver::Locator) ? from_element.strategies_and_selectors : nil

      begin
        ss = strategies_and_selectors[ss_index % strategies_and_selectors.count]
        ss_index +=1

        puts "Executing #{from_element_id ? "from #{from_element.strategy}: #{from_element.strategies_and_selectors} => " : ""}#{ss.keys[0]}: #{ss.values[0]}"

        if @cache[:selector] != ss.values[0] || # cache miss, selector is different
            @cache[:time] + 5 <= Time.now || # cache miss, older than 5 seconds
            @cache[:strategy] != ss.keys[0] || # cache miss, different find strategy
            @cache[:from_element_id] != from_element_id || # cache miss, search is started from different element
            skip_cache # cache is skipped

          if ss.keys[0] == FIND_STRATEGY_IMAGE
            set_find_by_image_settings(ss.values[0].dup)
            if single
              execute_result = from_element.find_element_by_image(ss.values[0][:image])
            else
              execute_result = from_element.find_elements_by_image(ss.values[0][:image])
            end
            restore_set_by_image_settings
          else
            if single
              execute_result = from_element.find_element(ss)
            else
              execute_result = from_element.find_elements(ss)
            end
          end



          unless skip_cache
            @cache[:selector] = ss.values[0]
            @cache[:strategy] = ss.keys[0]
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
        if (start_time + @implicit_wait_ms/1000 < Time.now.to_f && !ignore_implicit_wait) || ss_index < strategies_and_selectors.count
          sleep EXISTS_WAIT if ss_index >= strategies_and_selectors.count
          retry
        else
          raise e
        end
      ensure
        enable_implicit_wait
        enable_wait_for_idle
      end

      execute_result
    end


    # method missing is used to forward methods to the actual appium driver
    # after the method is executed, find element cache is invalidated
    def method_missing(method, *args, &block)
      r = @driver.send(method, *args, &block)
      invalidate_cache
      r
    end

    # disables implicit wait
    def disable_implicit_wait
      unless @implicit_wait_disabled
        @implicit_wait_ms = @driver.get_timeouts["implicit"]
        @implicit_wait_uiautomator_ms = @driver.get_settings["waitForSelectorTimeout"]
        @driver.manage.timeouts.implicit_wait = 0
        @driver.update_settings({waitForSelectorTimeout: 0})
        @implicit_wait_disabled = true
      end
    end

    # enables implicit wait, can be called only after disabling implicit wait
    def enable_implicit_wait
      unless @implicit_wait_disabled && @implicit_wait_ms.nil?
        @implicit_wait_ms = 10000
      end
      # get_timeouts always returns in milliseconds, but we should set in seconds
      @driver.manage.timeouts.implicit_wait = @implicit_wait_ms / 1000
      @driver.update_settings({waitForSelectorTimeout: @implicit_wait_uiautomator_ms})
      @implicit_wait_disabled = false
    end

    # disables wait for idle, only executed for android devices
    def disable_wait_for_idle
      unless @wait_for_idle_disabled
        if @device == :android
          @wait_for_idle_timeout = @driver.settings.get["waitForIdleTimeout"]
          @driver.update_settings({waitForIdleTimeout: 0})
        end
        @wait_for_idle_disabled = true
      end
    end

    # enables wait for idle, only executed for android devices
    def enable_wait_for_idle
      if @device == :android
        unless @wait_for_idle_disabled && @wait_for_idle_timeout.nil?
          @wait_for_idle_timeout = 10000
        end
        @driver.update_settings({waitForIdleTimeout: @wait_for_idle_timeout})
      end
    end

    def set_find_by_image_settings(settings)
      settings.delete(:image)
      @default_find_image_settings = {}
      old_settings = @driver.get_settings
      @default_find_image_settings[:imageMatchThreshold] = old_settings["imageMatchThreshold"]
      @default_find_image_settings[:fixImageFindScreenshotDims] = old_settings["fixImageFindScreenshotDims"]
      @default_find_image_settings[:fixImageTemplateSize] = old_settings["fixImageTemplateSize"]
      @default_find_image_settings[:fixImageTemplateScale] = old_settings["fixImageTemplateScale"]
      @default_find_image_settings[:defaultImageTemplateScale] = old_settings["defaultImageTemplateScale"]
      @default_find_image_settings[:checkForImageElementStaleness] = old_settings["checkForImageElementStaleness"]
      @default_find_image_settings[:autoUpdateImageElementPosition] = old_settings["autoUpdateImageElementPosition"]
      @default_find_image_settings[:imageElementTapStrategy] = old_settings["imageElementTapStrategy"]
      @default_find_image_settings[:getMatchedImageResult] = old_settings["getMatchedImageResult"]

      @driver.update_settings(settings)
    end

    def restore_set_by_image_settings
      @driver.update_settings(@default_find_image_settings) if @default_find_image_settings
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

    def tab_key
      @driver.press_keycode(61)
    end

    def dpad_up_key
      @driver.press_keycode(19)
    end

    def dpad_down_key
      @driver.press_keycode(20)
    end

    def dpad_right_key
      @driver.press_keycode(22)
    end

    def dpad_left_key
      @driver.press_keycode(23)
    end

    def enter_key
      @driver.press_keycode(66)
    end

    def press_keycode(code)
      @driver.press_keycode(code)
    end

    def long_press_keycode(code)
      @driver.long_press_keycode(code)
    end

    def click(x, y)
      ws = driver.window_size
      window_width = ws.width.to_i
      window_height = ws.height.to_i
      if x.kind_of? Integer
        if x < 0
          x = window_width + x
        end
      elsif x.kind_of? Float
        x = window_width*x
      else
        raise "x value #{x} not supported"
      end

      if y.kind_of? Integer
        if y < 0
          y = window_height + y
        end
      elsif y.kind_of? Float
        y = window_height*y
      end


      action_builder = @driver.action
      f1 = action_builder.add_pointer_input(:touch, "finger1")
      f1.create_pointer_move(duration: 0, x: x, y: y, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
      f1.create_pointer_down(:left)
      f1.create_pointer_up(:left)
      @driver.perform_actions [f1]
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
