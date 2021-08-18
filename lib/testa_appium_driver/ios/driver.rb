require_relative 'type_selectors'
require_relative 'locator'
require_relative 'selenium_element'

module TestaAppiumDriver
  class Driver
    include TypeSelectors


    def handle_testa_opts
      if @testa_opts[:default_find_strategy].nil?
        @default_find_strategy = DEFAULT_IOS_FIND_STRATEGY
      else
        case @testa_opts[:default_find_strategy].to_sym
        when FIND_STRATEGY_XPATH
          @default_find_strategy = @testa_opts[:default_find_strategy].to_sym
        else
          raise "Default find strategy #{@testa_opts[:default_find_strategy]} not supported for iOS"
        end
      end


      if @testa_opts[:default_scroll_strategy].nil?
        @default_scroll_strategy = DEFAULT_IOS_SCROLL_STRATEGY
      else
        case @testa_opts[:default_scroll_strategy].to_sym
        when SCROLL_STRATEGY_W3C
          @default_scroll_strategy = @testa_opts[:default_scroll_strategy].to_sym
        else
          raise "Default scroll strategy #{@testa_opts[:default_scroll_strategy]} not supported for iOS"
        end
      end
    end
  end
end