module TestaAppiumDriver
  class Locator

    def self.define_attribute_method(name, driver_method = nil)
      driver_method = name if driver_method.nil?

      define_method name do
        eles = execute

        @driver.disable_wait_for_idle
        if @single
          r = eles.send(:attribute, driver_method.to_s)
          r = TestaAppiumDriver::Bounds.from_android(r, @driver) if driver_method.to_s == "bounds"
        else
          r = eles.map { |e| e.send(:attribute, driver_method.to_s) }
          r.map! { |b| TestaAppiumDriver::Bounds.from_android(b, @driver) } if driver_method.to_s == "bounds"
        end
        @driver.enable_wait_for_idle
        r
      end
    end

    define_attribute_method(:text)
    define_attribute_method(:package)
    define_attribute_method(:class_name, :className)
    define_attribute_method(:checkable?, :checkable)
    define_attribute_method(:checked?, :checked)
    define_attribute_method(:clickable?, :clickable)
    define_attribute_method(:desc, :contentDescription)
    define_attribute_method(:enabled?, :enabled)
    define_attribute_method(:focusable?, :focusable)
    define_attribute_method(:focused?, :focused)
    define_attribute_method(:long_clickable?, :longClickable)
    define_attribute_method(:password?, :password)
    define_attribute_method(:id, :resourceId)
    define_attribute_method(:scrollable?, :scrollable)
    define_attribute_method(:selected?, :selected)
    define_attribute_method(:displayed?, :displayed)
    define_attribute_method(:selection_start, "selection-start")
    define_attribute_method(:selection_end, "selection-end")
    define_attribute_method(:bounds, :bounds)
  end
end