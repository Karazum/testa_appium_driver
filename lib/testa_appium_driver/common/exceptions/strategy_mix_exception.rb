module TestaAppiumDriver
  class StrategyMixException < Exception
    def initialize(strategy, strategy_reason, mixed_strategy, mixed_reason)
      msg = "strategy mix exception: '#{strategy_reason}' is only available in #{strategy} and cannot be used with '#{mixed_reason}' which is only available in #{mixed_strategy} strategy"
      super(msg)
    end
  end

end