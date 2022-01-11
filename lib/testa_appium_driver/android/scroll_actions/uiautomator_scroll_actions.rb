module TestaAppiumDriver
  #noinspection RubyInstanceMethodNamingConvention
  class ScrollActions
    private

    def uiautomator_scroll_to_start_or_end(type)

      scrollable_selector = @scrollable.ui_selector(false)
      orientation = @scrollable.scroll_orientation == :vertical ? ".setAsVerticalList()" : ".setAsHorizontalList()"
      scroll_command = type == :start ? ".scrollToBeginning(#{DEFAULT_UIAUTOMATOR_MAX_SWIPES})" : ".scrollToEnd(#{DEFAULT_UIAUTOMATOR_MAX_SWIPES})"
      cmd = "new UiScrollable(#{scrollable_selector})#{orientation}#{scroll_command};"
      begin
        puts "Scroll execute[uiautomator_#{type}]: #{cmd}"
        @driver.find_element(uiautomator: cmd)
      rescue
        # Ignored
      end


    end


    def uiautomator_scroll_to
      raise "UiAutomator scroll cannot work with specified direction" unless @direction.nil?

      scrollable_selector = @scrollable.ui_selector(false)
      element_selector = @locator.ui_selector(false)
      orientation_command = @scrollable.scroll_orientation == :vertical ? ".setAsVerticalList()" : ".setAsHorizontalList()"
      cmd = "new UiScrollable(#{scrollable_selector})#{orientation_command}.scrollIntoView(#{element_selector});"
      begin
        puts "Scroll execute[uiautomator_scroll_to]: #{cmd}"
        @driver.find_element(uiautomator: cmd)
      rescue
        # Ignored
      ensure
      end
    end


    def uiautomator_page_or_fling(type, direction)
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
    end


  end

end