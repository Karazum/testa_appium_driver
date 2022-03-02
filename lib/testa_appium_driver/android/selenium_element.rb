module ::Appium
  module Core
    class Element
      include TestaAppiumDriver::ClassSelectors
      include TestaAppiumDriver::Attributes

      def parent
        self.find_element(xpath: "./..")
      end
    end
  end
end