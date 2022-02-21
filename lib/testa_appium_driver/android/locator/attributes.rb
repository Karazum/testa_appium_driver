module TestaAppiumDriver
  module Attributes

    #noinspection RubyNilAnalysis
    def testa_attribute(name, *args)
      if self.instance_of?(::Selenium::WebDriver::Element) || self.instance_of?(::Appium::Core::Element)
        @driver = get_driver # does not get correct driver
        elements = self
      else
        elements = execute(*args)
        raise "Element not found" if elements.nil?
      end



      if elements.kind_of?(::Selenium::WebDriver::Element) || elements.kind_of?(::Appium::Core::Element)
        r = elements.send(:attribute, name.to_s)
        r = TestaAppiumDriver::Bounds.from_android(r, @driver) if name.to_s == "bounds"
      else
        r = elements.map { |e| e.send(:attribute, name.to_s) }
        r.map! { |b| TestaAppiumDriver::Bounds.from_android(b, @driver) } if name.to_s == "bounds"
      end
      r
    end

    def text(*args)
      testa_attribute("text", *args)
    end

    def package(*args)
      testa_attribute("package", *args)
    end

    def class_name(*args)
      testa_attribute("className", *args)
    end

    def checkable?(*args)
      testa_attribute("checkable", *args).to_s == "true"
    end

    def checked?(*args)
      testa_attribute("checked", *args).to_s == "true"
    end

    def clickable?(*args)
      testa_attribute("clickable", *args).to_s == "true"
    end

    def desc(*args)
      testa_attribute("contentDescription", *args)
    end

    def enabled?(*args)
      testa_attribute("enabled", *args).to_s == "true"
    end

    def focusable?(*args)
      testa_attribute("focusable", *args).to_s == "true"
    end

    def focused?(*args)
      testa_attribute("focused", *args).to_s == "true"
    end

    def long_clickable?(*args)
      testa_attribute("longClickable", *args).to_s == "true"
    end

    def password?(*args)
      testa_attribute("password", *args).to_s == "true"
    end

    def id(*args)
      testa_attribute("resourceId", *args)
    end

    def scrollable?(*args)
      testa_attribute("scrollable", *args).to_s == "true"
    end

    def selected?(*args)
      testa_attribute("selected", *args).to_s == "true"
    end

    def displayed?(*args)
      testa_attribute("displayed", *args).to_s == "true"
    end

    def selection_start(*args)
      testa_attribute("selection-start", *args)
    end

    def selection_end(*args)
      testa_attribute("selection-end", *args)
    end

    def bounds(*args)
      testa_attribute("bounds", *args)
    end

  end

  class Locator

    # element index in parent element, starts from 0
    #noinspection RubyNilAnalysis,RubyYardReturnMatch
    # @return [Integer, nil] index of element
    def index(*args)
      raise "Index not supported for uiautomator strategy" if @strategy == FIND_STRATEGY_UIAUTOMATOR
      this = execute(*args)
      children = self.dup.parent.children.execute
      index = children.index(this)
      raise "Index not found" if index.nil?
      index.to_i
    end
  end
end