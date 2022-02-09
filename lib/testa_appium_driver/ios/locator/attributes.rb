module TestaAppiumDriver
  module Attributes

    #noinspection RubyNilAnalysis
    def attribute(name, *args)
      elements = execute(*args)

      if elements.instance_of?(Selenium::WebDriver::Element) || elements.instance_of?(Appium::Core::Element)
        r = elements.send(:attribute, name.to_s)
        r = TestaAppiumDriver::Bounds.from_ios(r, @driver) if name.to_s == "rect"
      else
        r = elements.map { |e| e.send(:attribute, name.to_s) }
        r.map! { |b| TestaAppiumDriver::Bounds.from_ios(b, @driver) } if name.to_s == "rect"
      end
      r
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


    alias_method :bounds, :rect
    alias_method :text, :label
  end
  #noinspection RubyYardReturnMatch
  class Locator
    include TestaAppiumDriver::Attributes
  end
end