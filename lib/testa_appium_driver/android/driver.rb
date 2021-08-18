require_relative 'class_selectors'
require_relative 'locator'
require_relative 'scroll_actions/uiautomator_scroll_actions'
require_relative 'selenium_element'

module TestaAppiumDriver
  class Driver
    include ClassSelectors


    # @param [String] command Shell command name to execute for example echo or rm
    # @param [Array<String>] args Array of command arguments, example: ['-f', '/sdcard/my_file.txt']
    # @param [Integer] timeout Command timeout in milliseconds. If the command blocks for longer than this timeout then an exception is going to be thrown. The default timeout is 20000 ms
    # @param [Boolean] includeStderr 	Whether to include stderr stream into the returned result.
    #noinspection RubyParameterNamingConvention
    def shell(command, args: nil, timeout: nil, includeStderr: true)
      params = {
          command: command,
          includeStderr: includeStderr
      }
      params[:args] = args unless args.nil?
      params[:timeout] = timeout unless timeout.nil?
      @driver.execute_script("mobile: shell", params)
    end


    def handle_testa_opts
      if @testa_opts[:default_find_strategy].nil?
        @default_find_strategy = DEFAULT_ANDROID_FIND_STRATEGY
      else
        case @testa_opts[:default_find_strategy].to_sym
        when FIND_STRATEGY_UIAUTOMATOR, FIND_STRATEGY_XPATH
          @default_find_strategy = @testa_opts[:default_find_strategy].to_sym
        else
          raise "Default find strategy #{@testa_opts[:default_find_strategy]} not supported"
        end
      end


      if @testa_opts[:default_scroll_strategy].nil?
        @default_scroll_strategy = DEFAULT_ANDROID_SCROLL_STRATEGY
      else
        case @testa_opts[:default_scroll_strategy].to_sym
        when SCROLL_STRATEGY_W3C, SCROLL_STRATEGY_UIAUTOMATOR
          @default_scroll_strategy = @testa_opts[:default_scroll_strategy].to_sym
        else
          raise "Default scroll strategy #{@testa_opts[:default_scroll_strategy]} not supported"
        end
      end
    end
  end
end