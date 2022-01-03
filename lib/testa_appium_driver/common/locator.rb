require_relative 'locator/scroll_actions'


module TestaAppiumDriver
  #noinspection RubyTooManyInstanceVariablesInspection,RubyTooManyMethodsInspection
  class Locator
    include Helpers

    attr_accessor :xpath_selector
    attr_accessor :single

    attr_accessor :driver
    attr_accessor :strategy
    attr_accessor :strategy_reason

    # @type [Boolean] used to determine if last selector was one of siblings or children. Only in those selectors we can reliably use xpath array [instance] selector
    attr_accessor :last_selector_adjacent
    attr_accessor :can_use_id_strategy

    attr_accessor :image_selector

    attr_accessor :from_element
    attr_accessor :scroll_orientation
    attr_accessor :scroll_deadzone
    attr_accessor :scrollable_locator

    attr_accessor :default_find_strategy
    attr_accessor :default_scroll_strategy

    attr_accessor :index_for_multiple


    # locator parameters are:
    #   single: true or false
    #   scrollable_locator: [TestaAppiumDriver::Locator, nil] for scrolling if needed later
    #   default_find_strategy: default strategy if find element strategy is not enforced
    #   default_scroll_strategy: default strategy for scrolling if not enforced
    #
    # @param [TestaAppiumDriver::Driver] driver
    # @param [TestaAppiumDriver::Driver, TestaAppiumDriver::Locator, Selenium::WebDriver::Element] from_element from which element to execute the find_element
    # @param [Hash] params selectors and params for locator
    def initialize(driver, from_element, params = {})
      # @type [TestaAppiumDriver::Driver]
      @driver = driver
      @index_for_multiple = nil
      @image_selector = nil

      params, selectors = extract_selectors_from_params(params)
      single = params[:single]

      @single = single

      if selectors[:image].nil?
        if from_element.instance_of?(TestaAppiumDriver::Locator) && !from_element.image_selector.nil?
          raise "Cannot chain non-image selectors to image selectors"
        end
      else
        handle_image_selector(selectors, params)
      end

      selectors[:id] = selectors[:name] unless selectors[:name].nil?
      if from_element.instance_of?(Selenium::WebDriver::Element)
        @xpath_selector = "//*" # to select current element
        @xpath_selector += hash_to_xpath(@driver.device, selectors, single)[1..-1]
      else
        @xpath_selector = hash_to_xpath(@driver.device, selectors, single)
      end


      @from_element = from_element
      @default_find_strategy = params[:default_find_strategy]
      @default_scroll_strategy = params[:default_scroll_strategy]


      @can_use_id_strategy = is_only_id_selector?(selectors)
      if @can_use_id_strategy
        if @driver.device == :android
          @can_use_id_strategy = resolve_id(selectors[:id])
        else
          @can_use_id_strategy = selectors[:id]
        end
      end


      @strategy = params[:strategy]
      @strategy_reason = params[:strategy_reason]

      @last_selector_adjacent = false

      init(params, selectors, single)
    end




    def is_only_id_selector?(selectors)
      # since, name and id is the same thing for iOS,
      if @driver.device == :android
        selectors.keys.count == 1 && !selectors[:id].nil?
      else
        # if it iOS we assign the name to id
        selectors.keys.count == 2 && !selectors[:id].nil? && selectors[:id] == selectors[:name]
      end
    end


    # method missing is used to fetch the element before executing additional commands like click, send_key, count
    def method_missing(method, *args, &block)
      r = execute.send(method, *args, &block)
      @driver.invalidate_cache
      r
    end


    # @param [Boolean] skip_cache if true it will skip cache check and store
    # @param [Selenium::WebDriver::Element] force_cache_element, for internal use where we have already the element, and want to execute custom locator methods on it
    # @return [Selenium::WebDriver::Element, Array]
    def execute(skip_cache: false, force_cache_element: nil, ignore_implicit_wait: false)
      return force_cache_element unless force_cache_element.nil?
      # if we are looking for current element, then return from_element
      # for example when we have driver.element.elements[1].click
      # elements[2] will be resolved with xpath because we are looking for multiple elements from element
      # and since we are looking for instance 2, [](instance) method will return new "empty locator"
      # we are executing click on that "empty locator" so we have to return the instance 2 of elements for the click
      if @xpath_selector == "//*[1]" && !@from_element.nil? && @image_selector.nil?
        return @from_element if @from_element.instance_of?(Selenium::WebDriver::Element)
        return @from_element.execute(skip_cache: skip_cache, force_cache_element: force_cache_element, ignore_implicit_wait: ignore_implicit_wait) if @from_element.instance_of?(TestaAppiumDriver::Locator)
        return @from_element
      end






      r = @driver.execute(@from_element, @single, strategies_and_selectors, skip_cache: skip_cache, ignore_implicit_wait: ignore_implicit_wait)
      r = r[@index_for_multiple] if !@index_for_multiple.nil? && !@single
      r
    end

    def when_exists(timeout = nil, &block)
      found = false
      begin
        wait_until_exists(timeout)
        found = true
      rescue
        #ignored
      end
      if found
        if block_given? # block is given
          block.call(self) # use call to execute the block
        else # the value of block_argument becomes nil if you didn't give a block
          # block was not given
        end
      end
      self
    end


    # @param [Integer] timeout in seconds
    # @return [TestaAppiumDriver::Locator]
    def wait_until_exists(timeout = nil)
      args = {timeout: timeout}
      _wait(:until, args)
    end


    # @param [Integer] timeout in seconds
    # @return [TestaAppiumDriver::Locator]
    def wait_while_exists(timeout = nil)
      args = {timeout: timeout}
      _wait(:while, args)
    end


    def wait_while(timeout = nil, args = {})
      args[:timeout] = timeout
      _wait(:while, args)
    end

    def wait_until(timeout = nil, args = {})
      args[:timeout] = timeout
      _wait(:until, args)
    end


    # all timeouts are disabled before check, and enabled after check
    # @return [boolean] true if it exists in the page regardless if visible or not
    def exists?
      found = true
      begin
        execute(skip_cache: true, ignore_implicit_wait: true)
      rescue StandardError
        found = false
      end
      found
    end

    # @return [TestaAppiumDriver::Locator]
    def first
      self[0]
    end

    # @return [TestaAppiumDriver::Locator]
    def second
      self[1]
    end

    # @return [TestaAppiumDriver::Locator]
    def third
      self[2]
    end

    # @return [TestaAppiumDriver::Locator]
    def last
      self[-1]
    end

    def [](instance)
      raise "Cannot add index selector to non-Array" if @single
      if ((@strategy.nil? && !@last_selector_adjacent && @driver.device == :android) || @strategy == FIND_STRATEGY_UIAUTOMATOR) && instance >= 0
        locator = self.dup
        locator.strategy = FIND_STRATEGY_UIAUTOMATOR
        locator.ui_selector = "#{@ui_selector}.instance(#{instance})"
        locator.single = true
        locator.can_use_id_strategy = false
        locator
      elsif (@driver.device == :ios && !@last_selector_adjacent && @strategy.nil?) || @strategy == FIND_STRATEGY_CLASS_CHAIN
        locator = self.dup
        locator.strategy = FIND_STRATEGY_CLASS_CHAIN
        locator.class_chain_selector += "[#{instance + 1}]"
        locator.single = true
        locator.can_use_id_strategy = false
        locator
      else
        from_element = self.dup
        from_element.index_for_multiple = instance
        params = {}.merge({single: true, scrollable_locator: @scrollable_locator})
        #params[:strategy] = FIND_STRATEGY_XPATH
        #params[:strategy_reason] = "retrieved instance of a array"
        params[:default_find_strategy] = @default_find_strategy
        params[:default_scroll_strategy] = @default_scroll_strategy
        Locator.new(@driver, from_element, params)
      end
    end


    # @param [TestaAppiumDriver::Locator, Selenium::WebDriver::Element, Array] other
    #noinspection RubyNilAnalysis,RubyUnnecessaryReturnStatement
    def ==(other)
      elements = execute
      other = other.execute if other.kind_of?(TestaAppiumDriver::Locator)

      if elements.kind_of?(Array)
        return false unless other.kind_of?(Array)
        return false if other.count != elements.count
        return (elements - other).empty?
      else
        return false if other.kind_of?(Array)
        return elements == other
      end
    end

    def as_json
      {
          strategy: @strategy,
          default_strategy: @default_find_strategy,
          single: @single,
          context: @from_element.nil? ? nil : @from_element.to_s,
          uiautomator: defined?(self.ui_selector) ? ui_selector : nil,
          xpath: @xpath_selector,
          scrollable: @scrollable_locator.nil? ? nil : @scrollable_locator.to_s,
          scroll_orientation: @scroll_orientation,
          resolved: strategies_and_selectors,
          index_for_multiple: @index_for_multiple
      }
    end

    def to_s
      JSON.dump(as_json)
    end

    def to_ary
      [self.to_s]
    end


    # @return [TestaAppiumDriver::Locator]
    def as_scrollable(orientation: :vertical, top: nil, bottom: nil, right: nil, left: nil)
      @scroll_orientation = orientation
      if !top.nil? || !bottom.nil? || !right.nil? || !left.nil?
        @scroll_deadzone = {}
        @scroll_deadzone[:top] = top.to_f unless top.nil?
        @scroll_deadzone[:bottom] = bottom.to_f unless bottom.nil?
        @scroll_deadzone[:right] = right.to_f unless right.nil?
        @scroll_deadzone[:left] = left.to_f unless left.nil?
      end
      @scrollable_locator = self.dup
      self
    end


    def first_and_last_leaf
      @driver.first_and_last_leaf(execute)
    end


    def tap(x = nil, y = nil)
      click(x, y)
    end

    # if both x or y, or both are not given, will click in the center of the element
    # @param x If positive integer, will offset the click from the left side, if negative integer, will offset the click  from the right. If float value is given, it will threat it as percentage offset, giving it 0.5 will click in the middle
    # @param y If positive integer, will offset the click from the bottom side, if negative integer, will offset the click  from the top. If float value is given, it will threat it as percentage offset, giving it 0.5 will click in the middle
    def click(x = nil, y = nil)
      if !x.nil? && !y.nil?

        b = self.bounds
        if x.kind_of? Integer
          if x >= 0
            x = b.top_left.x + x
          else
            x = b.bottom_right.x + x
          end
        elsif x.kind_of? Float
          x = b.top_left.x + b.width*x
        else
          raise "x value #{x} not supported"
        end

        if y.kind_of? Integer
          if y >= 0
            y = b.bottom_right.y + y
          else
            y = b.top_left + y
          end
        elsif y.kind_of? Float
          y = b.bottom_right.y + b.height*y
        end

        action_builder = @driver.action
        f1 = action_builder.add_pointer_input(:touch, "finger1")
        f1.create_pointer_move(duration: 0, x: x, y: y, origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
        f1.create_pointer_down(:left)
        f1.create_pointer_up(:left)
        @driver.perform_actions [f1]
      else
        if @driver.device == :android
          perform_driver_method(:click)
        else
          # on ios, if element is not visible, first click will scroll to it
          # then on second click actually perform the click
          visible = visible?
          perform_driver_method(:click)
          perform_driver_method(:click) unless visible rescue nil
        end
      end
    end

    def send_key(*args)
      perform_driver_method(:send_keys, *args)
    end

    def clear
      perform_driver_method(:clear)
    end


    # Return parent element
    # @return [TestaAppiumDriver::Locator]
    def parent
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "parent") if @strategy != FIND_STRATEGY_XPATH && !@strategy.nil?
      raise "Cannot add parent selector to a retrieved instance of a class array" if (@xpath_selector == "//*" || @xpath_selector == "//*[1]")  && !@from_element.nil?

      locator = self.dup
      locator.strategy = FIND_STRATEGY_XPATH
      locator.strategy_reason = "parent"
      locator.xpath_selector += "/.."
      locator.can_use_id_strategy = false
      locator
    end

    # Return all children elements
    # @return [TestaAppiumDriver::Locator]
    def children
      raise "Cannot add children selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "children") if @strategy != FIND_STRATEGY_XPATH &&  @strategy != FIND_STRATEGY_CLASS_CHAIN && !@strategy.nil?

      locator = self.dup
      locator.strategy_reason = "children"
      locator.xpath_selector += "/*"
      locator.single = false
      locator.last_selector_adjacent = true
      locator.can_use_id_strategy = false

      if @driver.device == :android
        locator.strategy = FIND_STRATEGY_XPATH
      else
        locator.class_chain_selector += "/*"
      end
      locator
    end


    # Return first child element
    # @return [TestaAppiumDriver::Locator]
    def child
      raise "Cannot add children selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "child") if @strategy != FIND_STRATEGY_XPATH && @strategy != FIND_STRATEGY_CLASS_CHAIN && !@strategy.nil?

      locator = self.dup

      locator.strategy_reason = "child"
      locator.xpath_selector += "/*[1]"
      locator.single = true
      locator.can_use_id_strategy = false

      if @driver.device == :android
        locator.strategy = FIND_STRATEGY_XPATH
      else
        locator.class_chain_selector += "/*[1]"
      end
      locator
    end


    # @return [TestaAppiumDriver::Locator]
    def siblings
      raise "Cannot add siblings selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "siblings") if @strategy != FIND_STRATEGY_XPATH && !@strategy.nil?
      raise "Cannot add siblings selector to a retrieved instance of a class array" if (@xpath_selector == "//*" || @xpath_selector == "//*[1]")  && !@from_element.nil?

      locator = self.dup
      locator.strategy = FIND_STRATEGY_XPATH
      locator.strategy_reason = "siblings"
      locator.xpath_selector += "/../*[not(@index=\"#{index}\")]"
      locator.single = false
      locator.last_selector_adjacent = true
      locator.can_use_id_strategy = false
      locator
    end

    # @return [TestaAppiumDriver::Locator]
    def preceding_siblings
      raise "Cannot add preceding_siblings selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "preceding_siblings") if @strategy != FIND_STRATEGY_XPATH && !@strategy.nil?
      raise "Cannot add preceding_siblings selector to a retrieved instance of a class array" if (@xpath_selector == "//*" || @xpath_selector == "//*[1]")  && !@from_element.nil?

      locator = self.dup
      locator.strategy = FIND_STRATEGY_XPATH
      locator.strategy_reason = "preceding_siblings"
      locator.xpath_selector += "/../*[position() < #{index + 1}]" # position() starts from 1
      locator.single = false
      locator.last_selector_adjacent = true
      locator.can_use_id_strategy = false
      locator
    end

    # @return [TestaAppiumDriver::Locator]
    def preceding_sibling
      raise "Cannot add preceding_sibling selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "preceding_sibling") if @strategy != FIND_STRATEGY_XPATH && !@strategy.nil?
      raise "Cannot add preceding siblings selector to a retrieved instance of a class array" if (@xpath_selector == "//*" || @xpath_selector == "//*[1]")  && !@from_element.nil?

      locator = self.dup
      locator.strategy = FIND_STRATEGY_XPATH
      locator.strategy_reason = "preceding_sibling"
      i = index
      locator.single = true
      return nil if i == 0
      locator.xpath_selector += "/../*[@index=\"#{i - 1}\"]"
      locator.last_selector_adjacent = true
      locator.can_use_id_strategy = false
      locator
    end


    # @return [TestaAppiumDriver::Locator]
    def following_siblings
      raise "Cannot add following_siblings selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "following_siblings") if @strategy != FIND_STRATEGY_XPATH && !@strategy.nil?
      raise "Cannot add following_siblings selector to a retrieved instance of a class array" if (@xpath_selector == "//*" || @xpath_selector == "//*[1]")  && !@from_element.nil?

      locator = self.dup
      locator.strategy = FIND_STRATEGY_XPATH
      locator.strategy_reason = "following_siblings"
      locator.xpath_selector += "/../*[position() > #{index + 1}]" # position() starts from 1
      locator.single = false
      locator.last_selector_adjacent = true
      locator.can_use_id_strategy = false
      locator
    end

    # @return [TestaAppiumDriver::Locator]
    def following_sibling
      raise "Cannot add following_sibling selector to array" unless @single
      raise StrategyMixException.new(@strategy, @strategy_reason, FIND_STRATEGY_XPATH, "following_sibling") if @strategy != FIND_STRATEGY_XPATH && !@strategy.nil?
      raise "Cannot add following_sibling selector to a retrieved instance of a class array" if (@xpath_selector == "//*" || @xpath_selector == "//*[1]")  && !@from_element.nil?

      locator = self.dup
      locator.strategy = FIND_STRATEGY_XPATH
      locator.strategy_reason = "following_sibling"
      i = index
      locator.single = true
      return nil if i == 0
      locator.xpath_selector += "/../*[@index=\"#{i + 1}\"]"
      locator.last_selector_adjacent = true
      locator.can_use_id_strategy = false
      locator
    end


    private

    def _wait(type, args)
      interval = EXISTS_WAIT
      interval = args[:interval] unless args[:interval].nil?

      message = "wait #{type} exists timeout exceeded"
      message = args[:message] unless args[:message].nil?

      if args[:timeout].nil?
        #timeout = @driver.get_timeouts["implicit"] / 1000
        timeout = 10
      else
        timeout = args[:timeout]
      end

      args.delete(:message)
      args.delete(:interval)
      args.delete(:timeout)



      start_time = Time.now.to_f
      if type ==  :while
        while exists? && _attributes_match(args)
          raise message if start_time + timeout < Time.now.to_f
          sleep interval
        end
      else
        until exists? && _attributes_match(args)
          raise message if start_time + timeout < Time.now.to_f
          sleep interval
        end
      end
      self
    end

    def _attributes_match(attributes)
      all_match = true
      attributes.each do |key, value|
        unless attribute(key) == value
          all_match = false
          break
        end
      end
      all_match
    end

    #noinspection RubyNilAnalysis
    def perform_driver_method(name, *args)
      elements = execute
      if elements.kind_of?(Array)
        elements.map { |e| e.send(name, *args) }
      else
        elements.send(name, *args)
      end
    end

    def add_xpath_child_selectors(locator, selectors, single)
      locator.single = false unless single # switching from single result to multiple
      locator.xpath_selector += hash_to_xpath(@driver.device, selectors, single)
    end


    def handle_image_selector(selectors, params)
      image_match_threshold = 0.4
      image_match_threshold = params[:imageMatchThreshold] unless params[:imageMatchThreshold].nil?
      image_match_threshold = params[:threshold] unless params[:threshold].nil?
      fix_image_find_screenshot_dims = true
      fix_image_find_screenshot_dims = params[:fixImageFindScreenshotDims] unless params[:fixImageFindScreenshotDims].nil?
      fix_image_template_size = false
      fix_image_template_size = params[:fixImageTemplateSize] unless params[:fixImageTemplateSize].nil?
      fix_image_template_scale = false
      fix_image_template_scale = params[:fixImageTemplateScale] unless params[:fixImageTemplateScale].nil?
      default_image_template_scale = 1.0
      default_image_template_scale = params[:defaultImageTemplateScale] unless params[:defaultImageTemplateScale].nil?
      check_for_image_element_staleness = true
      check_for_image_element_staleness = params[:checkForImageElementStaleness] unless params[:checkForImageElementStaleness].nil?
      auto_update_image_element_position = false
      auto_update_image_element_position = params[:autoUpdateImageElementPosition] unless params[:autoUpdateImageElementPosition].nil?
      image_element_tap_strategy = "w3cActions"
      image_element_tap_strategy = params[:imageElementTapStrategy] unless params[:imageElementTapStrategy].nil?
      get_matched_image_result = false
      get_matched_image_result = params[:getMatchedImageResult] unless params[:getMatchedImageResult].nil?

      @image_selector = {
        image: selectors[:image],
        imageMatchThreshold: image_match_threshold,
        fixImageFindScreenshotDims: fix_image_find_screenshot_dims,
        fixImageTemplateSize: fix_image_template_size,
        fixImageTemplateScale: fix_image_template_scale,
        defaultImageTemplateScale: default_image_template_scale,
        checkForImageElementStaleness: check_for_image_element_staleness,
        autoUpdateImageElementPosition: auto_update_image_element_position,
        imageElementTapStrategy: image_element_tap_strategy,
        getMatchedImageResult: get_matched_image_result,
      }
    end
  end

end