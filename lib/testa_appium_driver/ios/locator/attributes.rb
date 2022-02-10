module TestaAppiumDriver
  module Attributes

    #noinspection RubyNilAnalysis
    def testa_attribute(name, *args)

      if self.instance_of?(::Selenium::WebDriver::Element) || self.instance_of?(::Appium::Core::Element)
        @driver = get_driver
        elements = self
      else
        elements = execute(*args)
      end


      if elements.instance_of?(::Selenium::WebDriver::Element) || elements.instance_of?(::Appium::Core::Element)
        r = elements.send(:attribute, name.to_s)
        r = TestaAppiumDriver::Bounds.from_ios(r, @driver) if name.to_s == "rect"
      else
        r = elements.map { |e| e.send(:attribute, name.to_s) }
        r.map! { |b| TestaAppiumDriver::Bounds.from_ios(b, @driver) } if name.to_s == "rect"
      end
      r
    end


    def accessibility_container(*args)
      testa_attribute("accessibilityContainer", *args)
    end

    def accessible?(*args)
      testa_attribute("accessible", *args).to_s == "true"
    end


    def class_name(*args)
      testa_attribute("class", *args)
    end

    def enabled?(*args)
      testa_attribute("enabled", *args).to_s == "true"
    end

    def frame(*args)
      testa_attribute("frame", *args)
    end

    def index(*args)
      testa_attribute("index", *args)
    end

    def label(*args)
      testa_attribute("label", *args)
    end

    def name(*args)
      testa_attribute("name", *args)
    end


    def rect(*args)
      testa_attribute("rect", *args)
    end

    def selected?(*args)
      testa_attribute("selected", *args).to_s == "true"
    end

    def type(*args)
      testa_attribute("type", *args)
    end

    def value(*args)
      testa_attribute("value", *args)
    end

    def visible?(*args)
      testa_attribute("visible", *args).to_s == "true"
    end


    alias_method :bounds, :rect
    alias_method :text, :label
  end

end