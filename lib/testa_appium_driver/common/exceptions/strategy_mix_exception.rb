module TestaAppiumDriver
  class StrategyMixException < Exception
    def initialize(strategy, strategy_reason, mixed_strategy, mixed_reason)

      # example: parent is only available in xpath strategy and cannot be used with from_element which is only available in uiautomator strategy
      msg = "strategy mix exception: '#{strategy_reason}' is only available in #{strategy} strategy and cannot be used with '#{mixed_reason}' which is only available in #{mixed_strategy} strategy"

      super(msg)
    end
  end

end