module TestaAppiumDriver
  module Helpers
    def hash_to_uiautomator(hash, single = true)
      command = "new UiSelector()"

      if hash[:id] && hash[:id].kind_of?(String) && !hash[:id].match?(/.*:id\//)
        # shorthand ids like myId make full ids => my.app.package:id/myId
        hash[:id] = "#{@driver.current_package}:id/#{hash[:id]}"
      end
      command = "#{ command }.resourceId(\"#{ %(#{ hash[:id] }) }\")" if hash[:id] && hash[:id].kind_of?(String)
      command = "#{ command }.resourceIdMatches(\"#{ %(#{ hash[:id].source }) }\")" if hash[:id] && hash[:id].kind_of?(Regexp)
      command = "#{ command }.longClickable(#{ hash[:longClickable] })" if hash[:longClickable]
      command = "#{ command }.description(\"#{ %(#{ hash[:desc] }) }\")" if hash[:desc] && hash[:desc].kind_of?(String)
      command = "#{ command }.descriptionMatches(\"#{ %(#{ hash[:desc].source }) }\")" if hash[:desc] && hash[:desc].kind_of?(Regexp)
      command = "#{ command }.className(\"#{ %(#{ hash[:class] }) }\")" if hash[:class] && hash[:class].kind_of?(String)
      command = "#{ command }.classNameMatches(\"#{ %(#{ hash[:class].source }) }\")" if hash[:class] && hash[:class].kind_of?(Regexp)
      command = "#{ command }.text(\"#{ %(#{ hash[:text] }) }\")" if hash[:text] && hash[:text].kind_of?(String)
      command = "#{ command }.textMatches(\"#{ %(#{ hash[:text].source }) }\")" if hash[:text] && hash[:text].kind_of?(Regexp)
      command = "#{ command }.packageName(\"#{ %(#{ hash[:package] }) }\")" if hash[:package] && hash[:package].kind_of?(String)
      command = "#{ command }.packageNameMatches(\"#{ %(#{ hash[:package].source }) }\")" if hash[:package] && hash[:package].kind_of?(Regexp)

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

      command = "#{ command }[@long-clickable=\"#{ hash[:longClickable] }\"]" if hash[:longClickable]
      command = "#{ command }[@content-desc=\"#{ %(#{hash[:desc] }) }\"]" if hash[:desc] && hash[:desc].kind_of?(String)
      command = "#{ command }[contains(@content-desc, \"#{ %(#{hash[:desc].source }) }\")]" if hash[:desc] && hash[:desc].kind_of?(Regexp)
      command = "#{ command }[contains(@class, \"#{ %(#{hash[:class].source }) }\")]" if hash[:class] && hash[:class].kind_of?(Regexp)
      command = "#{ command }[@text=\"#{ %(#{hash[:text] }) }\"]" if hash[:text] && hash[:text].kind_of?(String)
      command = "#{ command }[contains(@text, \"#{ %(#{hash[:text].source }) }\")]" if hash[:text] && hash[:text].kind_of?(Regexp)
      command = "#{ command }[@package=\"#{ %(#{hash[:package] }) }\"]" if hash[:package] && hash[:package].kind_of?(String)
      command = "#{ command }[contains=(@package, \"#{ %(#{hash[:package].source }) }\")]" if hash[:package] && hash[:package].kind_of?(Regexp)

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

    def is_scrollable_selector(selectors, single)
      return false unless single
      return true if selectors[:scrollable]
      if selectors[:class] == "androidx.recyclerview.widget.RecyclerView" ||
        selectors[:class] == "android.widget.HorizontalScrollView" ||
        selectors[:class] == "android.widget.ScrollView" ||
        selectors[:class] == "android.widget.ListView"
        true
      end
    end

    #noinspection RubyUnnecessaryReturnStatement,RubyUnusedLocalVariable
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
      params[:default_strategy] = DEFAULT_FIND_STRATEGY if params[:default_strategy].nil?

      return params, selectors
    end
  end
end