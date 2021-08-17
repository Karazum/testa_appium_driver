module TestaAppiumDriver
  class Locator


    #noinspection RubyNilAnalysis
    def attribute(name, *args)
      elements = execute(*args)

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
    def checkable(*args)
      attribute("checkable", *args)
    end
    def checked(*args)
      attribute("checked", *args)
    end
    def clickable(*args)
      attribute("clickable", *args)
    end
    def desc(*args)
      attribute("contentDescription", *args)
    end
    def enabled(*args)
      attribute("enabled", *args)
    end
    def focusable(*args)
      attribute("focusable", *args)
    end
    def focused(*args)
      attribute("focused", *args)
    end
    def long_clickable(*args)
      attribute("longClickable", *args)
    end
    def password(*args)
      attribute("password", *args)
    end
    def id(*args)
      attribute("resourceId", *args)
    end
    def scrollable(*args)
      attribute("scrollable", *args)
    end
    def selected(*args)
      attribute("selected", *args)
    end
    def displayed(*args)
      attribute("displayed", *args)
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
end