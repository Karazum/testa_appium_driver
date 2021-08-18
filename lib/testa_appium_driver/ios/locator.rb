require_relative 'locator/attributes'

module TestaAppiumDriver
  #noinspection RubyTooManyInstanceVariablesInspection
  class Locator
    include TypeSelectors

    def init(params, selectors, single)
      if is_scrollable_selector?(selectors, single)
        @scroll_orientation = :vertical
        params[:scrollable_locator] = self.dup
      end

      @scrollable_locator = params[:scrollable_locator] if params[:scrollable_locator]
    end


    def selector
      @xpath_selector
    end


    # @return [Locator] existing locator element
    def add_child_selector(params)
      params, selectors = extract_selectors_from_params(params)
      single = params[:single]
      raise "Cannot add child selector to Array" if single && !@single

      locator = self.dup
      add_xpath_child_selectors(locator, selectors, single)
      if is_scrollable_selector?(selectors, single)
        locator.scrollable_locator.scroll_orientation = :vertical
        locator.scrollable_locator = self.dup
      end

      locator.last_selector_adjacent = false
      locator
    end
  end
end