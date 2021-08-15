module TestaAppiumDriver
  class Locator

    def align(with = :top) end

    def scroll(params) end

    def scroll_to(params = {})
      params[:max_scrolls] = 5 unless params[:max_scrolls]
      params[:direction] = :down unless params[:direction]
      params[:align] = :top unless params[:align]

      rounds = 0
      max_rounds_reached = false
      until self.exists?
        scroll(params)

        rounds += 1
        max_rounds_reached = true if rounds == params[:max_scrolls]
        break if rounds == params[:max_scrolls]
      end

      unless max_rounds_reached
        # align the element at the top of the screen

        align(params[:align])

        return self
      end
      raise "Element cannot be found"
    end
  end
end