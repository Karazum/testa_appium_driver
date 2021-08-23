# frozen_string_literal: true

#noinspection ALL
module TestaAppiumDriver
  FIND_STRATEGY_UIAUTOMATOR = :uiautomator
  FIND_STRATEGY_XPATH = :xpath
  FIND_STRATEGY_ID = :id
  FIND_STRATEGY_NAME = :name

  SCROLL_STRATEGY_UIAUTOMATOR = :uiautomator
  SCROLL_STRATEGY_W3C = :w3c


  SCROLL_CORRECTION_W3C = 30
  SCROLL_ALIGNMENT_THRESHOLD = 25

  SCROLL_ACTION_TYPE_SCROLL = :scroll
  SCROLL_ACTION_TYPE_FLING = :fling
  SCROLL_ACTION_TYPE_DRAG = :drag


  DEFAULT_UIAUTOMATOR_MAX_SWIPES = 20

  DEFAULT_ANDROID_FIND_STRATEGY = FIND_STRATEGY_UIAUTOMATOR
  DEFAULT_ANDROID_SCROLL_STRATEGY = SCROLL_STRATEGY_UIAUTOMATOR


  DEFAULT_IOS_FIND_STRATEGY = FIND_STRATEGY_XPATH
  DEFAULT_IOS_SCROLL_STRATEGY = SCROLL_STRATEGY_W3C

  DEFAULT_W3C_MAX_SCROLLS = 7

  EXISTS_WAIT = 0.5
  LONG_TAP_DURATION = 1.5
end