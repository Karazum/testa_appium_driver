module TestaAppiumDriver
  #noinspection ALL
  module TypeSelectors

    # @return [TestaAppiumDriver::Locator]
    def add_selector(*args, &block)
      # if class selector is executed from driver, create new locator instance
      if self.kind_of?(TestaAppiumDriver::Driver) || self.instance_of?(Selenium::WebDriver::Element)
        args.last[:default_find_strategy] = @default_find_strategy
        args.last[:default_scroll_strategy] = @default_scroll_strategy
        if self.instance_of?(Selenium::WebDriver::Element)
          driver = self.get_driver
        else
          driver = self
        end
        Locator.new(driver, self, *args)
      else
        # class selector is executed from locator, just add child selector criteria
        self.add_child_selector(*args)
      end
    end

    # @param selectors [Hash]
    # @return [TestaAppiumDriver::Locator] first element
    def element(selectors = {})
      add_selector(selectors)
    end

    # @param params [Hash]
    # @return [TestaAppiumDriver::Locator] all elements that match given selectors
    def elements(params = {})
      params[:single] = false
      add_selector(params)
    end


    # @return [TestaAppiumDriver::Locator]
    def window(params = {})
      params[:type] = "XCUIElementTypeWindow"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def windows(params = {})
      params[:type] = "XCUIElementTypeWindow"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def other(params = {})
      params[:type] = "XCUIElementTypeOther"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def others(params = {})
      params[:type] = "XCUIElementTypeOther"
      params[:single] = false
      add_selector(params)
    end


    # @return [TestaAppiumDriver::Locator]
    def navigation_bar(params = {})
      params[:type] = "XCUIElementTypeNavigationBar"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def navigation_bars(params = {})
      params[:type] = "XCUIElementTypeNavigationBar"
      params[:single] = false
      add_selector(params)
    end


    # @return [TestaAppiumDriver::Locator]
    def button(params = {})
      params[:type] = "XCUIElementTypeButton"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def buttons(params = {})
      params[:type] = "XCUIElementTypeButton"
      params[:single] = false
      add_selector(params)
    end


    # @return [TestaAppiumDriver::Locator]
    def image(params = {})
      params[:type] = "XCUIElementTypeImage"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def images(params = {})
      params[:type] = "XCUIElementTypeImage"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def static_text(params = {})
      params[:type] = "XCUIElementTypeStaticText"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def static_texts(params = {})
      params[:type] = "XCUIElementTypeStaticText"
      params[:single] = false
      add_selector(params)
    end


    # @return [TestaAppiumDriver::Locator]
    def scroll_view(params = {})
      params[:type] = "XCUIElementTypeScrollView"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def scroll_views(params = {})
      params[:type] = "XCUIElementTypeScrollView"
      params[:single] = false
      add_selector(params)
    end


    # @return [TestaAppiumDriver::Locator]
    def table(params = {})
      params[:type] = "XCUIElementTypeTable"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def tables(params = {})
      params[:type] = "XCUIElementTypeTable"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def cell(params = {})
      params[:type] = "XCUIElementTypeCell"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def cells(params = {})
      params[:type] = "XCUIElementTypeCell"
      params[:single] = false
      add_selector(params)
    end



    # @return [TestaAppiumDriver::Locator]
    def text_field(params = {})
      params[:type] = "XCUIElementTypeTextField"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def text_fields(params = {})
      params[:type] = "XCUIElementTypeTextField"
      params[:single] = false
      add_selector(params)
    end


    # @return [TestaAppiumDriver::Locator]
    def secure_text_field(params = {})
      params[:type] = "XCUIElementTypeSecureTextField"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def secure_text_fields(params = {})
      params[:type] = "XCUIElementTypeSecureTextField"
      params[:single] = false
      add_selector(params)
    end
  end
end