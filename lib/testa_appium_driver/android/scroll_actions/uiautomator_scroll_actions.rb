module TestaAppiumDriver
  class ScrollActions
    private

    def uiautomator_scroll_to
      raise "UiAutomator scroll cannot work with specified direction" unless @direction.nil?


      @driver.disable_wait_for_idle
      @driver.disable_implicit_wait

      scrollable_selector = @scrollable.ui_selector(false)
      element_selector = @locator.ui_selector(false)
      cmd = "new UiScrollable(#{scrollable_selector}).scrollIntoView(#{element_selector});"
      # TODO: support horizontal scroll to
      begin
        puts "Scroll execute[uiautomator_scroll_to]: #{cmd}"
        @driver.find_element(uiautomator: cmd)
      rescue
        # Ignored
      ensure
        @driver.enable_implicit_wait
        @driver.enable_wait_for_idle
      end

      @locator
    end


    def uiautomator_page_or_fling(type, direction)
      @driver.disable_wait_for_idle
      @driver.disable_implicit_wait

      scrollable_selector = @scrollable.ui_selector(false)
      orientation = direction == :up || direction == :down ? ".setAsVerticalList()" : ".setAsHorizontalList()"
      if type == SCROLL_ACTION_TYPE_SCROLL
        direction_command = direction == :down || direction == :right ? ".scrollForward()" : ".scrollBackward()"
      elsif type == SCROLL_ACTION_TYPE_FLING
        direction_command = direction == :down || direction == :right ? ".flingForward()" : ".flingBackward()"
      else
        raise "Unknown scroll action type #{type}"
      end
      cmd = "new UiScrollable(#{scrollable_selector})#{orientation}#{direction_command};"
      begin
        puts "Scroll execute[uiautomator_#{type}]: #{cmd}"
        @driver.find_element(uiautomator: cmd)
      rescue
        # Ignored
      end
      @driver.enable_implicit_wait
      @driver.enable_wait_for_idle
      @locator
    end


  end

end