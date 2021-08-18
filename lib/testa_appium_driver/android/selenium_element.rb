module Selenium
  module WebDriver
    class Element
      include TestaAppiumDriver::ClassSelectors
      include TestaAppiumDriver::AndroidAttributeModule
    end
  end
end