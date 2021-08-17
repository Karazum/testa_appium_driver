module TestaAppiumDriver
  #noinspection ALL
  module ClassSelectors

    # @return [TestaAppiumDriver::Locator]
    def add_selector(*args, &block)
      # if class selector is executed from driver, create new locator instance
      if self.kind_of?(TestaAppiumDriver::Driver)
        args.last[:default_find_strategy] = @default_find_strategy
        args.last[:default_scroll_strategy] = @default_scroll_strategy
        Locator.new(self, self, *args)
      else
        # class selector is executed from locator, just add child selector criteria
        self.add_child_selector(*args)
      end
    end

    # @param selectors [Hash]
    # @return [TestaAppiumDriver::Locator] first element
    def element(selectors = {})
      add_selector(selectors)
    end

    # @param params [Hash]
    # @return [TestaAppiumDriver::Locator] all elements that match given selectors
    def elements(params = {})
      params[:single] = false
      add_selector(params)
    end


    # @param selectors [Hash]
    # @return [TestaAppiumDriver::Locator] first scrollable element
    def scrollable(selectors = {})
      selectors[:scrollable] = true
      add_selector(selectors)
    end

    # @param params [Hash]
    # @return [TestaAppiumDriver::Locator] first scrollable element
    def scrollables(params = {})
      params[:scrollable] = true
      params[:single] = false
      add_selector(params)
    end


    # @return [TestaAppiumDriver::Locator]
    def image_view(params = {})
      params[:class] = "android.widget.ImageView"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def image_views(params = {})
      params[:class] = "android.widget.ImageView"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def frame_layout(params = {})
      params[:class] = "android.widget.FrameLayout"
      add_selector(params)
    end

    def frame_layouts(params = {})
      params[:class] = "android.widget.FrameLayout"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def linear_layout(params = {})
      params[:class] = "android.widget.LinearLayout"
      add_selector(params)
    end

    def linear_layouts(params = {})
      params[:class] = "android.widget.LinearLayout"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def view(params = {})
      params[:class] = "android.widget.View"
      add_selector(params)
    end

    def views(params = {})
      params[:class] = "android.widget.View"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def edit_text(params = {})
      params[:class] = "android.widget.EditText"
      add_selector(params)
    end

    def edit_texts(params = {})
      params[:class] = "android.widget.EditText"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def view_group(params = {})
      params[:class] = "android.widget.ViewGroup"
      add_selector(params)
    end

    def view_groups(params = {})
      params[:class] = "android.widget.ViewGroup"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def relative_layout(params = {})
      params[:class] = "android.widget.RelativeLayout"
      add_selector(params)
    end

    def relative_layouts(params = {})
      params[:class] = "android.widget.RelativeLayout"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def recycler_view(params = {})
      params[:class] = "androidx.recyclerview.widget.RecyclerView"
      add_selector(params)
    end

    def recycler_views(params = {})
      params[:class] = "androidx.recyclerview.widget.RecyclerView"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def button(params = {})
      params[:class] = "android.widget.Button"
      add_selector(params)
    end

    def buttons(params = {})
      params[:class] = "android.widget.Button"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def image_button(params = {})
      params[:class] = "android.widget.ImageButton"
      add_selector(params)
    end

    def image_buttons(params = {})
      params[:class] = "android.widget.ImageButton"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def horizontal_scroll_view(params = {})
      params[:class] = "android.widget.HorizontalScrollView"
      add_selector(params)
    end

    def horizontal_scroll_views(params = {})
      params[:class] = "android.widget.HorizontalScrollView"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def scroll_view(params = {})
      params[:class] = "android.widget.ScrollView"
      add_selector(params)
    end

    def scroll_views(params = {})
      params[:class] = "android.widget.ScrollView"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def view_pager(params = {})
      params[:class] = "androidx.viewpager.widget.ViewPager"
      add_selector(params)
    end

    def view_pagers(params = {})
      params[:class] = "androidx.viewpager.widget.ViewPager"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def check_box(params = {})
      params[:class] = "android.widget.CheckBox"
      add_selector(params)
    end

    def check_boxes(params = {})
      params[:class] = "android.widget.CheckBox"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def list_view(params = {})
      params[:class] = "android.widget.ListView"
      add_selector(params)
    end

    def list_views(params = {})
      params[:class] = "android.widget.ListView"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def progress_bar(params = {})
      params[:class] = "android.widget.ProgressBar"
      add_selector(params)
    end

    def progress_bars(params = {})
      params[:class] = "android.widget.ProgressBar"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def radio_button(params = {})
      params[:class] = "android.widget.RadioButton"
      add_selector(params)
    end

    def radio_buttons(params = {})
      params[:class] = "android.widget.RadioButton"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def radio_group(params = {})
      params[:class] = "android.widget.RadioGroup"
      add_selector(params)
    end

    def radio_groups(params = {})
      params[:class] = "android.widget.RadioGroup"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def search_view(params = {})
      params[:class] = "android.widget.SearchView"
      add_selector(params)
    end

    def search_views(params = {})
      params[:class] = "android.widget.SearchView"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def spinner(params = {})
      params[:class] = "android.widget.Spinner"
      add_selector(params)
    end

    def spinners(params = {})
      params[:class] = "android.widget.Spinner"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def toast(params = {})
      params[:class] = "android.widget.Toast"
      add_selector(params)
    end

    def toasts(params = {})
      params[:class] = "android.widget.Toast"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def toolbar(params = {})
      params[:class] = "android.widget.Toolbar"
      add_selector(params)
    end

    def toolbars(params = {})
      params[:class] = "android.widget.Toolbar"
      params[:single] = false
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def text_view(params = {})
      params[:class] = "android.widget.TextView"
      add_selector(params)
    end

    # @return [TestaAppiumDriver::Locator]
    def text_views(params = {})
      params[:class] = "android.widget.TextView"
      params[:single] = false
      add_selector(params)
    end

  end
end