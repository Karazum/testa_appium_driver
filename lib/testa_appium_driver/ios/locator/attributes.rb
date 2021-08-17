module TestaAppiumDriver
  #noinspection RubyYardReturnMatch
  class Locator


    #noinspection RubyNilAnalysis
    def attribute(name, *args)
      elements = execute(*args)

      if elements.kind_of?(Selenium::WebDriver::Element)
        r = elements.send(:attribute, name.to_s)
        r = TestaAppiumDriver::Bounds.from_ios(r, @driver) if name.to_s == "rect"
      else
        r = elements.map { |e| e.send(:attribute, name.to_s) }
        r.map! { |b| TestaAppiumDriver::Bounds.from_ios(b, @driver) } if name.to_s == "rect"
      end
      r
    end


    def text
      label
    end

    def accessibility_container(*args)
      attribute("accessibilityContainer", *args)
    end

    def accessible?(*args)
      attribute("accessible", *args).to_s == "true"
    end


    def class_name(*args)
      attribute("class", *args)
    end

    def enabled?(*args)
      attribute("enabled", *args).to_s == "true"
    end

    def frame(*args)
      attribute("frame", *args)
    end

    def index(*args)
      attribute("index", *args)
    end

    def label(*args)
      attribute("label", *args)
    end

    def name(*args)
      attribute("name", *args)
    end

    def bounds(*args)
      rect(*args)
    end

    def rect(*args)
      attribute("rect", *args)
    end

    def selected?(*args)
      attribute("selected", *args).to_s == "true"
    end

    def type(*args)
      attribute("type", *args)
    end

    def value(*args)
      attribute("value", *args)
    end

    def visible?(*args)
      attribute("visible", *args).to_s == "true"
    end


  end
end