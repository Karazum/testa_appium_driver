module Selenium
  module WebDriver
    #noinspection RubyClassVariableUsageInspection
    class Element
      def self.set_driver(driver, udid)
        udid = "unknown" if udid.nil?
        @@drivers ||= {}
        @@drivers[udid] = driver
      end

      def get_driver
        udid = @bridge.capabilities.instance_variable_get(:@capabilities)["udid"]
        udid = "unknown" if udid.nil?
        @@drivers[udid]
      end

    end
  end
end
