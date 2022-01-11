module Selenium
  module WebDriver
    class Element
      # sets the testa appium driver instance for the current phone
      def self.set_driver(driver, udid)
        udid = "unknown" if udid.nil?
        @@drivers ||= {}
        @@drivers[udid] = driver
      end

      # @return [TestaAppiumDriver::Driver] testa appium driver instance for the current phone
      def get_driver
        udid = @bridge.capabilities.instance_variable_get(:@capabilities)["udid"]
        udid = "unknown" if udid.nil?
        @@drivers[udid]
      end
    end
  end
end
