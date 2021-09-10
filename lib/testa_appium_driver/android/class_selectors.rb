module TestaAppiumDriver
  #noinspection ALL
  module ClassSelectors

    # @return [TestaAppiumDriver::Locator]
    def add_selector(*args, &block)
      # if class selector is executed from driver, create new locator instance
      if self.kind_of?(TestaAppiumDriver::Driver) || self.instance_of?(Selenium::WebDriver::Element)
        args.last[:default_find_strategy] = @default_find_strategy
        args.last[:default_scroll_strategy] = @default_scroll_strategy
        if self.instance_of?(Selenium::WebDriver::Element)
          driver = self.get_driver
        else
          driver = self
        end
        Locator.new(driver, self, *args)
      else
        # class selector is executed from locator, just add child selector criteria
        self.add_child_selector(*args)
      end
    end

    # first element that match given selectors
    # @param selectors [Hash]
    # @return [TestaAppiumDriver::Locator] first element
    def element(selectors = {})
      unless selectors[:image].nil?
        selectors[:strategy] = FIND_STRATEGY_IMAGE
      end
      add_selector(selectors)
    end

    # all elements that match given selectors
    # @param params [Hash]
    # @return [TestaAppiumDriver::Locator] all elements that match given selectors
    def elements(params = {})
      unless params[:image].nil?
        params[:strategy] = FIND_STRATEGY_IMAGE
      end
      params[:single] = false
      add_selector(params)
    end


    # first android.widget.ImageView element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def image_view(params = {})
      params[:class] = "android.widget.ImageView"
      add_selector(params)
    end

    # all android.widget.ImageView elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def image_views(params = {})
      params[:class] = "android.widget.ImageView"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.FrameLayout element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def frame_layout(params = {})
      params[:class] = "android.widget.FrameLayout"
      add_selector(params)
    end

    # all android.widget.FrameLayout elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def frame_layouts(params = {})
      params[:class] = "android.widget.FrameLayout"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.LinearLayout element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def linear_layout(params = {})
      params[:class] = "android.widget.LinearLayout"
      add_selector(params)
    end

    # all android.widget.LinearLayout elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def linear_layouts(params = {})
      params[:class] = "android.widget.LinearLayout"
      params[:single] = false
      add_selector(params)
    end

    # first android.view.View element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def view(params = {})
      params[:class] = "android.view.View"
      add_selector(params)
    end

    # all android.view.View elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def views(params = {})
      params[:class] = "android.view.View"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.EditText element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def edit_text(params = {})
      params[:class] = "android.widget.EditText"
      add_selector(params)
    end

    # all android.widget.EditText elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def edit_texts(params = {})
      params[:class] = "android.widget.EditText"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.ViewGroup element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def view_group(params = {})
      params[:class] = "android.widget.ViewGroup"
      add_selector(params)
    end

    # all android.widget.ViewGroup elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def view_groups(params = {})
      params[:class] = "android.widget.ViewGroup"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.RelativeLayout element that match given selecotrs
    # @return [TestaAppiumDriver::Locator]
    def relative_layout(params = {})
      params[:class] = "android.widget.RelativeLayout"
      add_selector(params)
    end

    # all android.widget.RelativeLayout elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def relative_layouts(params = {})
      params[:class] = "android.widget.RelativeLayout"
      params[:single] = false
      add_selector(params)
    end

    # first androidx.recyclerview.widget.RecyclerView element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def recycler_view(params = {})
      params[:class] = "androidx.recyclerview.widget.RecyclerView"
      add_selector(params)
    end

    # all androidx.recyclerview.widget.RecyclerView elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def recycler_views(params = {})
      params[:class] = "androidx.recyclerview.widget.RecyclerView"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.Button element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def button(params = {})
      params[:class] = "android.widget.Button"
      add_selector(params)
    end

    # all android.widget.Button elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def buttons(params = {})
      params[:class] = "android.widget.Button"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.ImageButton element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def image_button(params = {})
      params[:class] = "android.widget.ImageButton"
      add_selector(params)
    end

    # all android.widget.ImageButton elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def image_buttons(params = {})
      params[:class] = "android.widget.ImageButton"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.HorizontalScrollView element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def horizontal_scroll_view(params = {})
      params[:class] = "android.widget.HorizontalScrollView"
      add_selector(params)
    end

    # all android.widget.HorizontalScrollView elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def horizontal_scroll_views(params = {})
      params[:class] = "android.widget.HorizontalScrollView"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.ScrollView element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def scroll_view(params = {})
      params[:class] = "android.widget.ScrollView"
      add_selector(params)
    end

    # all android.widget.ScrollView elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def scroll_views(params = {})
      params[:class] = "android.widget.ScrollView"
      params[:single] = false
      add_selector(params)
    end

    # first viewpager.widget.ViewPager element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def view_pager(params = {})
      params[:class] = "androidx.viewpager.widget.ViewPager"
      add_selector(params)
    end

    # all viewpager.widget.ViewPager elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def view_pagers(params = {})
      params[:class] = "androidx.viewpager.widget.ViewPager"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.CheckBox element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def check_box(params = {})
      params[:class] = "android.widget.CheckBox"
      add_selector(params)
    end

    # all android.widget.CheckBox elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def check_boxes(params = {})
      params[:class] = "android.widget.CheckBox"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.ListView element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def list_view(params = {})
      params[:class] = "android.widget.ListView"
      add_selector(params)
    end

    # all android.widget.ListView elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def list_views(params = {})
      params[:class] = "android.widget.ListView"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.ProgressBar element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def progress_bar(params = {})
      params[:class] = "android.widget.ProgressBar"
      add_selector(params)
    end

    # all android.widget.ProgressBar elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def progress_bars(params = {})
      params[:class] = "android.widget.ProgressBar"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.RadioButton element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def radio_button(params = {})
      params[:class] = "android.widget.RadioButton"
      add_selector(params)
    end

    # all android.widget.RadioButton elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def radio_buttons(params = {})
      params[:class] = "android.widget.RadioButton"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.RadioGroup element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def radio_group(params = {})
      params[:class] = "android.widget.RadioGroup"
      add_selector(params)
    end

    # all android.widget.RadioGroup elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def radio_groups(params = {})
      params[:class] = "android.widget.RadioGroup"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.SearchView element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def search_view(params = {})
      params[:class] = "android.widget.SearchView"
      add_selector(params)
    end

    # all android.widget.SearchView elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def search_views(params = {})
      params[:class] = "android.widget.SearchView"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.Spinner element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def spinner(params = {})
      params[:class] = "android.widget.Spinner"
      add_selector(params)
    end

    # all android.widget.Spinner elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def spinners(params = {})
      params[:class] = "android.widget.Spinner"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.Toast element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def toast(params = {})
      params[:class] = "android.widget.Toast"
      add_selector(params)
    end

    # all android.widget.Toast elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def toasts(params = {})
      params[:class] = "android.widget.Toast"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.Toolbar element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def toolbar(params = {})
      params[:class] = "android.widget.Toolbar"
      add_selector(params)
    end

    # all android.widget.Toolbar elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def toolbars(params = {})
      params[:class] = "android.widget.Toolbar"
      params[:single] = false
      add_selector(params)
    end

    # first android.widget.TextView element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def text_view(params = {})
      params[:class] = "android.widget.TextView"
      add_selector(params)
    end

    # all android.widget.TextView elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def text_views(params = {})
      params[:class] = "android.widget.TextView"
      params[:single] = false
      add_selector(params)
    end


    # first androidx.cardview.widget.CardView element that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def card_view(params = {})
      params[:class] = "androidx.cardview.widget.CardView"
      add_selector(params)
    end

    # all androidx.cardview.widget.CardView elements that match given selectors
    # @return [TestaAppiumDriver::Locator]
    def card_views(params = {})
      params[:class] = "androidx.cardview.widget.CardView"
      params[:single] = false
      add_selector(params)
    end


  end
end