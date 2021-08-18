module TestaAppiumDriver
  module AndroidAttributeModule

    #noinspection RubyNilAnalysis
    def attribute(name, *args)
      elements = execute(*args)

      @driver = get_driver if self.instance_of?(Selenium::WebDriver::Element)

      @driver.disable_wait_for_idle
      if elements.kind_of?(Selenium::WebDriver::Element)
        r = elements.send(:attribute, name.to_s)
        r = TestaAppiumDriver::Bounds.from_android(r, @driver) if name.to_s == "bounds"
      else
        r = elements.map { |e| e.send(:attribute, name.to_s) }
        r.map! { |b| TestaAppiumDriver::Bounds.from_android(b, @driver) } if name.to_s == "bounds"
      end
      @driver.enable_wait_for_idle
      r
    end

    def text(*args)
      attribute("text", *args)
    end

    def package(*args)
      attribute("package", *args)
    end

    def class_name(*args)
      attribute("className", *args)
    end

    def checkable?(*args)
      attribute("checkable", *args).to_s == "true"
    end

    def checked?(*args)
      attribute("checked", *args).to_s == "true"
    end

    def clickable?(*args)
      attribute("clickable", *args).to_s == "true"
    end

    def desc(*args)
      attribute("contentDescription", *args)
    end

    def enabled?(*args)
      attribute("enabled", *args).to_s == "true"
    end

    def focusable?(*args)
      attribute("focusable", *args).to_s == "true"
    end

    def focused?(*args)
      attribute("focused", *args).to_s == "true"
    end

    def long_clickable?(*args)
      attribute("longClickable", *args).to_s == "true"
    end

    def password(*args)
      attribute("password", *args)
    end

    def id(*args)
      attribute("resourceId", *args)
    end

    def scrollable?(*args)
      attribute("scrollable", *args).to_s == "true"
    end

    def selected?(*args)
      attribute("selected", *args).to_s == "true"
    end

    def displayed?(*args)
      attribute("displayed", *args).to_s == "true"
    end

    def selection_start(*args)
      attribute("selection-start", *args)
    end

    def selection_end(*args)
      attribute("selection-end", *args)
    end

    def bounds(*args)
      attribute("bounds", *args)
    end

  end

  class Locator
    include TestaAppiumDriver::AndroidAttributeModule


    # element index in parent element, starts from 0
    #noinspection RubyNilAnalysis,RubyYardReturnMatch
    # @return [Integer, nil] index of element
    def index(*args)
      raise "Index not supported for uiautomator strategy" if @strategy == FIND_STRATEGY_UIAUTOMATOR
      this = execute(*args)
      children = self.dup.parent.children.execute
      index = children.index(this)
      raise "Index not found" if index.nil?
      index
    end
  end
end