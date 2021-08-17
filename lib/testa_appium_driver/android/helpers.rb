module TestaAppiumDriver
  module Helpers

    # supported selectors
    # id: "com.my.package:id/myId"
    # id: "myId" => will be converted to "com.my.package:id/myId"
    # id: /my/ will find all elements with ids that contain my
    # desc: "element description"
    # desc: /ription/ will find all elements that contains ription
    # class: "android.widget.Button"
    # class: /Button/ will find all elements with classes that contain Button
    # text: "Hello world"
    # text: /ello/ will find all elements with text that contain ello
    # package: "com.my.package"
    # package: /my/ will find all elements with package that contains my
    # long_clickable: true or false
    # checkable: true or false
    # checked: true or false
    # clickable: true or false
    # enabled: true or false
    # focusable: true or false
    # focused: true or false
    # index: child index inside of a parent element, index starts from 0
    # selected: true or false
    # scrollable: true or false
    # @param [Hash] hash selectors for finding elements
    # @param [Boolean] single should the command return first instance or all of matched elements
    # @return [String] hash selectors converted to uiautomator command
    def hash_to_uiautomator(hash, single = true)
      command = "new UiSelector()"

      if hash[:id] && hash[:id].kind_of?(String) && !hash[:id].match?(/.*:id\//)
        # shorthand ids like myId make full ids => my.app.package:id/myId
        hash[:id] = "#{@driver.current_package}:id/#{hash[:id]}"
      end
      command = "#{ command }.resourceId(\"#{ %(#{ hash[:id] }) }\")" if hash[:id] && hash[:id].kind_of?(String)
      command = "#{ command }.resourceIdMatches(\"#{ %(#{ hash[:id].source }) }\")" if hash[:id] && hash[:id].kind_of?(Regexp)
      command = "#{ command }.description(\"#{ %(#{ hash[:desc] }) }\")" if hash[:desc] && hash[:desc].kind_of?(String)
      command = "#{ command }.descriptionMatches(\"#{ %(#{ hash[:desc].source }) }\")" if hash[:desc] && hash[:desc].kind_of?(Regexp)
      command = "#{ command }.className(\"#{ %(#{ hash[:class] }) }\")" if hash[:class] && hash[:class].kind_of?(String)
      command = "#{ command }.classNameMatches(\"#{ %(#{ hash[:class].source }) }\")" if hash[:class] && hash[:class].kind_of?(Regexp)
      command = "#{ command }.text(\"#{ %(#{ hash[:text] }) }\")" if hash[:text] && hash[:text].kind_of?(String)
      command = "#{ command }.textMatches(\"#{ %(#{ hash[:text].source }) }\")" if hash[:text] && hash[:text].kind_of?(Regexp)
      command = "#{ command }.packageName(\"#{ %(#{ hash[:package] }) }\")" if hash[:package] && hash[:package].kind_of?(String)
      command = "#{ command }.packageNameMatches(\"#{ %(#{ hash[:package].source }) }\")" if hash[:package] && hash[:package].kind_of?(Regexp)

      command = "#{ command }.longClickable(#{ hash[:long_clickable] })" if hash[:long_clickable]
      command = "#{ command }.checkable(#{ hash[:checkable] })" unless hash[:checkable].nil?
      command = "#{ command }.checked(#{ hash[:checked] })" unless hash[:checked].nil?
      command = "#{ command }.clickable(#{ hash[:clickable] })" unless hash[:clickable].nil?
      command = "#{ command }.enabled(#{ hash[:enabled] })" unless hash[:enabled].nil?
      command = "#{ command }.focusable(#{ hash[:focusable] })" unless hash[:focusable].nil?
      command = "#{ command }.focused(#{ hash[:focused] })" unless hash[:focused].nil?
      command = "#{ command }.index(#{ hash[:index].to_s })" unless hash[:index].nil?
      command = "#{ command }.selected(#{ hash[:selected] })" unless hash[:selected].nil?
      command = "#{ command }.scrollable(#{ hash[:scrollable] })" unless hash[:scrollable].nil?

      command += ".instance(0)" if single

      command
    end


    # supported selectors
    # id: "com.my.package:id/myId"
    # id: "myId" => will be converted to "com.my.package:id/myId"
    # id: /my/ will find all elements with ids that contain my
    # desc: "element description"
    # desc: /ription/ will find all elements that contains ription
    # class: "android.widget.Button"
    # class: /Button/ will find all elements with classes that contain Button
    # text: "Hello world"
    # text: /ello/ will find all elements with text that contain ello
    # package: "com.my.package"
    # package: /my/ will find all elements with package that contains my
    # long_clickable: true or false
    # checkable: true or false
    # checked: true or false
    # clickable: true or false
    # enabled: true or false
    # focusable: true or false
    # focused: true or false
    # index: child index inside of a parent element, index starts from 0
    # selected: true or false
    # scrollable: true or false
    # @param [Hash] hash selectors for finding elements
    # @param [Boolean] single should the command return first instance or all of matched elements
    # @return [String] hash selectors converted to xpath command
    def hash_to_xpath(hash, single = true)
      command = "//"

      if hash[:id] && hash[:id].kind_of?(String) && !hash[:id].match?(/.*:id\//)
        # shorthand ids like myId make full ids => my.app.package:id/myId
        hash[:id] = "#{@driver.current_package}:id/#{hash[:id]}"
      end
      if hash[:class] && hash[:class].kind_of?(String)
        command = "#{ command }#{hash[:class] }"
      else
        command = "#{ command}*"
      end

      command = "#{ command }[@resource-id=\"#{ %(#{hash[:id] }) }\"]" if hash[:id] && hash[:id].kind_of?(String)
      command = "#{ command }[contains(@resource-id, \"#{ %(#{hash[:id].source }) }\")]" if hash[:id] && hash[:id].kind_of?(Regexp)

      command = "#{ command }[@content-desc=\"#{ %(#{hash[:desc] }) }\"]" if hash[:desc] && hash[:desc].kind_of?(String)
      command = "#{ command }[contains(@content-desc, \"#{ %(#{hash[:desc].source }) }\")]" if hash[:desc] && hash[:desc].kind_of?(Regexp)
      command = "#{ command }[contains(@class, \"#{ %(#{hash[:class].source }) }\")]" if hash[:class] && hash[:class].kind_of?(Regexp)
      command = "#{ command }[@text=\"#{ %(#{hash[:text] }) }\"]" if hash[:text] && hash[:text].kind_of?(String)
      command = "#{ command }[contains(@text, \"#{ %(#{hash[:text].source }) }\")]" if hash[:text] && hash[:text].kind_of?(Regexp)
      command = "#{ command }[@package=\"#{ %(#{hash[:package] }) }\"]" if hash[:package] && hash[:package].kind_of?(String)
      command = "#{ command }[contains=(@package, \"#{ %(#{hash[:package].source }) }\")]" if hash[:package] && hash[:package].kind_of?(Regexp)

      command = "#{ command }[@long-clickable=\"#{ hash[:long_clickable] }\"]" if hash[:long_clickable]
      command = "#{ command }[@checkable=\"#{ hash[:checkable] }\"]" unless hash[:checkable].nil?
      command = "#{ command }[@checked=\"#{ hash[:checked] }\"]" unless hash[:checked].nil?
      command = "#{ command }[@clickable=\"#{ hash[:clickable] }\"]" unless hash[:clickable].nil?
      command = "#{ command }[@enabled=\"#{ hash[:enabled] }\"]" unless hash[:enabled].nil?
      command = "#{ command }[@focusable=\"#{ hash[:focusable] }\"]" unless hash[:focusable].nil?
      command = "#{ command }[@focused=\"#{ hash[:focused] }\"]" unless hash[:focused].nil?
      command = "#{ command }[@index=\"#{ hash[:index] }\"]" unless hash[:index].nil?
      command = "#{ command }[@selected=\"#{ hash[:selected] }\"]" unless hash[:selected].nil?
      command = "#{ command }[@scrollable=\"#{ hash[:scrollable] }\"]" unless hash[:scrollable].nil?

      command += "[1]" if single

      command
    end

    # check if selectors are for a scrollable element
    # @param [Boolean] single should the command return first instance or all of matched elements
    # @param [Hash] selectors for fetching elements
    # @return [Boolean] true if element has scrollable attribute true or is class one of (RecyclerView, HorizontalScrollView, ScrollView, ListView)
    def is_scrollable_selector?(selectors, single)
      return false unless single
      return true if selectors[:scrollable]
      if selectors[:class] == "androidx.recyclerview.widget.RecyclerView" ||
        selectors[:class] == "android.widget.HorizontalScrollView" ||
        selectors[:class] == "android.widget.ScrollView" ||
        selectors[:class] == "android.widget.ListView"
        true
      end
      false
    end

    #noinspection RubyUnnecessaryReturnStatement,RubyUnusedLocalVariable
    # separate selectors from given hash parameters
    # @param [Hash] params
    # @return [Array] first element is params, second are selectors
    def extract_selectors_from_params(params = {})
      selectors = params.select { |key, value| [
        :id,
        :longClickable,
        :desc,
        :class,
        :text,
        :package,
        :checkable,
        :checked,
        :clickable,
        :enabled,
        :focusable,
        :focused,
        :index,
        :selected,
        :scrollable
      ].include?(key) }
      params = Hash[params.to_a - selectors.to_a]

      # default params
      params[:single] = true if params[:single].nil?
      params[:scrollable_locator] = nil if params[:scrollable_locator].nil?
      params[:default_find_strategy] = DEFAULT_FIND_STRATEGY if params[:default_find_strategy].nil?
      params[:default_scroll_strategy] = DEFAULT_SCROLL_STRATEGY if params[:default_scroll_strategy].nil?

      return params, selectors
    end
  end
end