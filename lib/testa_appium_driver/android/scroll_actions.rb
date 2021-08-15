module TestaAppiumDriver
  module ScrollActions

    # disable idle wait for specific methods
    def self.find_scrollable_if_called_from_driver
      ScrollActions.instance_methods.each { |m|
        # Rename original method
        self.send(:alias_method, "#{m}_orig", m)

        # Redefine old method with instrumentation code added
        define_method m do |*args, &block|
          # if scroll action is executed from driver, first find a scrollable
          if self.kind_of?(TestaAppiumDriver::Driver)
            self.scrollable.send("#{m}_orig", *args, &block)
          else
            # scroll action is executed from a locator, threat that locator as scrollable
            self.send("#{m}_orig", *args, &block)
          end
        end
      }
    end

  end
end