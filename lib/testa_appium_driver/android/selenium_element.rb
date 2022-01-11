module Selenium
  module WebDriver
    class Element
      include TestaAppiumDriver::ClassSelectors
      include TestaAppiumDriver::Attributes
    end
  end
end