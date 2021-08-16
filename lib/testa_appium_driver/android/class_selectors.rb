module TestaAppiumDriver
  #noinspection ALL
  module ClassSelectors

    def add_selector(*args, &block)
      # if class selector is executed from driver, create new locator instance
      if self.kind_of?(TestaAppiumDriver::Driver)
        args.last[:default_strategy] = @default_strategy
        Locator.new(self, self, *args)
      else
        # class selector is executed from locator, just add child selector criteria
        self.add_child_selector(*args)
      end
    end

    # @param selectors [Hash]
    # @return Selenium::WebDriver::Element first scrollable element
    def scrollable(selectors = {})
      selectors[:scrollable] = true
      add_selector(selectors)
    end

    def self.define_class_selector_method(name, class_name, single)
      single = true if single.kind_of?(Symbol) && single == :single
      single = false if single.kind_of?(Symbol) && single == :multiple

      define_method name do |*args|
        # set default argument as an empty selector (hash)
        args.push({}) if args.count == 0

        # set the selector class if class is provided
        args[0][:class] = class_name if class_name
        args.last[:single] = single
        add_selector(*args)
      end
    end

    define_class_selector_method(:element, nil, :single)
    define_class_selector_method(:elements, nil, :multiple)

    define_class_selector_method(:image_view, "android.widget.ImageView", :single)
    define_class_selector_method(:image_views, "android.widget.ImageView", :multiple)

    define_class_selector_method(:frame_layout, "android.widget.FrameLayout", :single)
    define_class_selector_method(:frame_layouts, "android.widget.FrameLayout", :multiple)

    define_class_selector_method(:linear_layout, "android.widget.LinearLayout", :single)
    define_class_selector_method(:linear_layouts, "android.widget.LinearLayout", :multiple)

    define_class_selector_method(:view, "android.widget.View", :single)
    define_class_selector_method(:views, "android.widget.View", :multiple)

    define_class_selector_method(:edit_text, "android.widget.EditText", :single)
    define_class_selector_method(:edit_texts, "android.widget.EditText", :multiple)

    define_class_selector_method(:view_group, "android.widget.ViewGroup", :single)
    define_class_selector_method(:view_groups, "android.widget.ViewGroup", :multiple)

    define_class_selector_method(:relative_layout, "android.widget.RelativeLayout", :single)
    define_class_selector_method(:relative_layouts, "android.widget.RelativeLayout", :multiple)

    define_class_selector_method(:recycler_view, "androidx.recyclerview.widget.RecyclerView", :single)
    define_class_selector_method(:recycler_views, "androidx.recyclerview.widget.RecyclerView", :multiple)

    define_class_selector_method(:button, "android.widget.Button", :single)
    define_class_selector_method(:buttons, "android.widget.Button", :multiple)

    define_class_selector_method(:image_button, "android.widget.ImageButton", :single)
    define_class_selector_method(:image_buttons, "android.widget.ImageButton", :multiple)

    define_class_selector_method(:horizontal_scroll_view, "android.widget.HorizontalScrollView", :single)
    define_class_selector_method(:horizontal_scroll_views, "android.widget.HorizontalScrollView", :multiple)

    define_class_selector_method(:scroll_view, "android.widget.ScrollView", :single)
    define_class_selector_method(:scroll_views, "android.widget.ScrollView", :multiple)

    define_class_selector_method(:view_pager, "androidx.viewpager.widget.ViewPager", :single)
    define_class_selector_method(:view_pagers, "androidx.viewpager.widget.ViewPager", :multiple)

    define_class_selector_method(:check_box, "android.widget.CheckBox", :single)
    define_class_selector_method(:check_boxes, "android.widget.CheckBox", :multiple)

    define_class_selector_method(:list_view, "android.widget.ListView", :single)
    define_class_selector_method(:list_views, "android.widget.ListView", :multiple)

    define_class_selector_method(:progress_bar, "android.widget.ProgressBar", :single)
    define_class_selector_method(:progress_bars, "android.widget.ProgressBar", :multiple)

    define_class_selector_method(:radio_button, "android.widget.RadioButton", :single)
    define_class_selector_method(:radio_buttons, "android.widget.RadioButton", :multiple)

    define_class_selector_method(:radio_group, "android.widget.RadioGroup", :single)
    define_class_selector_method(:radio_groups, "android.widget.RadioGroup", :multiple)

    define_class_selector_method(:search_view, "android.widget.SearchView", :single)
    define_class_selector_method(:search_views, "android.widget.SearchView", :multiple)

    define_class_selector_method(:spinner, "android.widget.Spinner", :single)
    define_class_selector_method(:spinners, "android.widget.Spinner", :multiple)

    define_class_selector_method(:toast, "android.widget.Toast", :single)
    define_class_selector_method(:toasts, "android.widget.Toast", :multiple)

    define_class_selector_method(:toolbar, "android.widget.Toolbar", :single)
    define_class_selector_method(:toolbars, "android.widget.Toolbar", :multiple)

    define_class_selector_method(:text_view, "android.widget.TextView", :single)
    define_class_selector_method(:text_views, "android.widget.TextView", :multiple)

  end
end