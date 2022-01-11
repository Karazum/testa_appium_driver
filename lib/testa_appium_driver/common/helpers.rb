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

      id = resolve_id(hash[:id])
      command = "#{ command }.resourceId(\"#{ %(#{ id }) }\")" if id && id.kind_of?(String)
      command = "#{ command }.resourceIdMatches(\".*#{ %(#{ id.source }) }.*\")" if id && id.kind_of?(Regexp)
      command = "#{ command }.description(\"#{ %(#{ hash[:desc] }) }\")" if hash[:desc] && hash[:desc].kind_of?(String)
      command = "#{ command }.descriptionMatches(\".*#{ %(#{ hash[:desc].source }) }.*\")" if hash[:desc] && hash[:desc].kind_of?(Regexp)
      command = "#{ command }.className(\"#{ %(#{ hash[:class] }) }\")" if hash[:class] && hash[:class].kind_of?(String)
      command = "#{ command }.classNameMatches(\".*#{ %(#{ hash[:class].source }) }.*\")" if hash[:class] && hash[:class].kind_of?(Regexp)
      command = "#{ command }.text(\"#{ %(#{ hash[:text] }) }\")" if hash[:text] && hash[:text].kind_of?(String)
      command = "#{ command }.textMatches(\".*#{ %(#{ hash[:text].source }) }.*\")" if hash[:text] && hash[:text].kind_of?(Regexp)
      command = "#{ command }.packageName(\"#{ %(#{ hash[:package] }) }\")" if hash[:package] && hash[:package].kind_of?(String)
      command = "#{ command }.packageNameMatches(\".*#{ %(#{ hash[:package].source }) }.*\")" if hash[:package] && hash[:package].kind_of?(Regexp)

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
    def hash_to_xpath(device, hash, single = true)
      for_android = device == :android


      command = "//"



      if for_android
        id = resolve_id(hash[:id])
        if hash[:class] && hash[:class].kind_of?(String)
          command = "#{ command }#{hash[:class] }"
        elsif hash[:class] && hash[:class].kind_of?(Regexp)
          command = "#{ command}*[contains(@class, \"#{ %(#{hash[:class].source }) }\")]"
        else
          command = "#{command}*"
        end


        command = "#{ command }[@resource-id=\"#{ %(#{ id }) }\"]" if  id &&  id.kind_of?(String)
        command = "#{ command }[contains(@resource-id, \"#{ %(#{ id.source }) }\")]" if  id &&  id.kind_of?(Regexp)
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

        # it seems like you cannot query by scrollable
        # command = "#{ command }[@scrollable=\"#{ hash[:scrollable] }\"]" unless hash[:scrollable].nil?
      else

        hash[:type] = hash[:class] unless hash[:class].nil?
        if hash[:type] && hash[:type].kind_of?(String)
          command = "#{ command }#{hash[:type] }"
        elsif hash[:type] && hash[:type].kind_of?(Regexp)
          command = "#{ command}*[contains(@type, \"#{ %(#{hash[:type].source }) }\")]"
        else
          command = "#{command}*"
        end


        #  # ios specific
        hash[:label] = hash[:text] unless hash[:text].nil?
        hash[:name] = hash[:id] unless hash[:id].nil?

        command = "#{ command }[@enabled=\"#{ hash[:enabled] }\"]" unless hash[:enabled].nil?
        command = "#{ command }[@label=\"#{ %(#{hash[:label] }) }\"]" if hash[:label] && hash[:label].kind_of?(String)
        command = "#{ command }[contains(@label, \"#{ %(#{hash[:label].source }) }\")]" if hash[:label] && hash[:label].kind_of?(Regexp)
        command = "#{ command }[@name=\"#{ %(#{hash[:name] }) }\"]" if hash[:name] && hash[:name].kind_of?(String)
        command = "#{ command }[contains(@name, \"#{ %(#{hash[:name].source }) }\")]" if hash[:name] && hash[:name].kind_of?(Regexp)
        command = "#{ command }[@value=\"#{ %(#{hash[:value] }) }\"]" if hash[:value] && hash[:value].kind_of?(String)
        command = "#{ command }[contains(@value, \"#{ %(#{hash[:value].source }) }\")]" if hash[:value] && hash[:value].kind_of?(Regexp)
        command = "#{ command }[@width=\"#{ hash[:width] }\"]" unless hash[:width].nil?
        command = "#{ command }[@height=\"#{ hash[:height] }\"]" unless hash[:height].nil?
        command = "#{ command }[@visible=\"#{ hash[:visible] }\"]" unless hash[:visible].nil?
      end


      command += "[1]" if single

      command
    end


    def hash_to_class_chain(hash, single = true)
      command = "**/"

      hash[:type] = hash[:class] unless hash[:class].nil?
      hash[:label] = hash[:text] unless hash[:text].nil?
      hash[:name] = hash[:id] unless hash[:id].nil?
      if hash[:type] && hash[:type].kind_of?(String)
        command = "#{ command }#{hash[:type] }"
      else
        command = "#{command}*"
      end

      command = "#{ command }[`enabled == #{ hash[:enabled] }`]" unless hash[:enabled].nil?
      command = "#{ command }[`label == \"#{ %(#{hash[:label] }) }\"`]" if hash[:label] && hash[:label].kind_of?(String)
      command = "#{ command }[`label CONTAINS \"#{ %(#{hash[:label].source }) }\"`]" if hash[:label] && hash[:label].kind_of?(Regexp)
      command = "#{ command }[`name == \"#{ %(#{hash[:name] }) }\"`]" if hash[:name] && hash[:name].kind_of?(String)
      command = "#{ command }[`name CONTAINS \"#{ %(#{hash[:name].source }) }\"`]" if hash[:name] && hash[:name].kind_of?(Regexp)
      command = "#{ command }[`value == \"#{ %(#{hash[:value] }) }\"`]" if hash[:value] && hash[:value].kind_of?(String)
      command = "#{ command }[`value CONTAINS \"#{ %(#{hash[:value].source }) }\"`]" if hash[:value] && hash[:value].kind_of?(Regexp)
      command = "#{ command }[`visible == #{ hash[:visible] }`]" unless hash[:visible].nil?

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
        return true
      elsif selectors[:type] == "XCUIElementTypeScrollView"
        return true
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
          :long_clickable,
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
          :scrollable,

          # ios specific
          :type,
          :label,
          :x,
          :y,
          :width,
          :height,
          :visible,
          :name,
          :value,

          :image
      ].include?(key) }
      params = Hash[params.to_a - selectors.to_a]

      # default params
      params[:single] = true if params[:single].nil?
      params[:scrollable_locator] = nil if params[:scrollable_locator].nil?
      if params[:default_find_strategy].nil?
        params[:default_find_strategy] = DEFAULT_ANDROID_FIND_STRATEGY if @driver.device == :android
        params[:default_find_strategy] = DEFAULT_IOS_FIND_STRATEGY if @driver.device == :ios || @driver.device == :tvos
      end
      if params[:default_scroll_strategy].nil?
        params[:default_scroll_strategy] = DEFAULT_ANDROID_SCROLL_STRATEGY if @driver.device == :android
        params[:default_scroll_strategy] = DEFAULT_IOS_SCROLL_STRATEGY if @driver.device == :ios || @driver.device == :tvos
      end

      return params, selectors
    end


    def resolve_id(id)
      if id && id.kind_of?(String) && !id.match?(/.*:id\//)
        # shorthand ids like myId make full ids => my.app.package:id/myId
        if id[0] == "="
          return id[1..-1]
        else
          return "#{@driver.current_package}:id/#{id}"
        end
      else
        id
      end
    end
  end
end