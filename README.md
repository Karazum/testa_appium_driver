# Testa Appium Driver

Testa appium driver is a wrapper around the `ruby_lib_core` driver for appium. 
It leverages all driver features and makes them simple and easy to use. 

There are two key concepts in the testa driver
#### 1. Elements are fetched only when needed
It allows you to chain all the selectors and use the adjacent selectors without finding each element in the chain.
For example `driver.linear_layout.list_view.view_group.button` will not execute any find element commands
because element command is not given. If `click`, `send_keys` or any attribute method is added to the end of chain
it will execute find_element before triggering the given element command.

This concept allows you to store the selectors and reuse them later on. For example
```ruby
# element is not fetched yet
my_fancy_progress_bar = driver.linear_layout.progress_bar

puts my_fancy_progress_bar.text # will fetch the element and print the text (output: "You are on the first page")
driver.button(text: "next page").click # go to the next page that has the same progress bar locator

# will fetch the element again and print the text (output: "You are on the second page")
# without TestaAppiumDriver, a Stale Object Exception would be thronw
puts my_fancy_progress_bar.text 
```


#### 2. The Best element find / scroll strategy is automatically determined
When given an element locator such as the progress_bar in the first concept, testa appium driver automatically determines
the best find element strategy. The only thing to keep in mind is that you cannot mix strategy specific selectors. 
Strategy specific selectors are `from_parent` for uiautomator or `parent`, `siblings` or `children` for xpath strategy.

There are also multiple scroll strategies. Android supports both `uiautomator` and `w3c`, while iOS only supports `w3c` 
scroll strategy. Uiautomator scroll strategy is more fluent and faster but it cannot be limited with single direction
 element finding, and it does not have sufficient deadzone support.      




## Installation

Add this line to your application's Gemfile:

```ruby
gem 'testa_appium_driver'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install testa_appium_driver
    
    
For the android platform, make sure you are using the latest version of uiautomator server. Versions older than 4.21.2 have breaking issues.
To get the latest server version execute:
```shell script
npm install appium-uiautomator2-server
``` 
And apks will be located in `./node_modules/appium-uiautomator2-server/apks`. Install both apks on the target device
and make sure you have the `skipServerInstallation: true` capability when starting the driver.
## Usage

### Initialization
```ruby
opts = {
    caps: {
        platformName: "Android",
        deviceName: "MyPhone",
        app: "/path/to/your/apk",
        udid: "your_phone_udid",
        automationName: "uiautomator2",
        skipServerInstallation: true, # if uiautomator server is manually installed
        enableMultiWindows: true, # enables appium to see some otherwise "hidden" elements
    }
}
driver = TestaAppiumDriver::Driver.new(opts)
```

#### Example 1 
```ruby
driver.linear_layout.button(id: "com.package.name:id/myElementId").click
```
Looks for the first linear layout and a button within the linear layout that has the provided id.
Only 1 find element is executed with the resolved strategy (xpath or uiautomator):<br>
underlying selectors:<br>
xpath: `//android.widget.LinearLayout[1]//android.widget.Button[@resource-id="com.package.name:id/myElementId"]` <br>
uiautomator: `new UiSelector().className("android.widget.LinearLayout").instance(0).childSelector(new UiSelector.className("android.widget.Button").resourceId("com.package.name:id/myElementId")));`<br>

#### Example 2
```ruby
driver.linear_layout(id: "myShortIdExample").parent.text_view.wait_until_exists(10).text
```
Testa driver converts shorthand ids(that dont have :id/) to full ids
by reading the current package under test and prepending it to the shorthand id. If you don't want to prepend the package
name to the id, use = sign before the id, for example `id: "=idWithoutAPackageName"`.

After adding the `parent` and `text_view` selectors and before retrieving the text value `wait_until_exists(10)` is used to
wait up to 10 seconds for the element to appear in the page before exception is thrown.  

underlying selectors:<br>
xpath: `//android.widget.LinearLayout[@resource-id="com.package.name:id/myShortIdExample"][1]/../android.widget.TextView[1]` <br>
uiautomator: `exception: parent selector cannot be used with uiautomator strategy`

#### Example 3
```ruby
driver.list_view(top: 200).edit_text(text: "Looking for this text").scroll_to.align!(:bottom).enabled?
```
If the element cannot be found in the current view, `scroll_to` action will scroll to start of the scrollable container,
and start scrolling to the end until the element is found or end is reached. Once found the `align!(:bottom)` command
will align the element to the bottom of the scrollable container.
Finally, once the element is scrolled into view and aligned, it will check if the edit_text is enabled.

The scrollable container is resolved by looking the chain of selectors. 
Selector can be a scrollable container if  `scrollable: true` or is one of the scrollable classes:
- android.widget.ListView
- android.widget.ScrollView
- android.widget.HorizontalScrollView
- androidx.recyclerview.widget.RecyclerView
- XCUIElementTypeScrollView

If the selector chain does not contain a scrollable container, a `driver.scrollabe` command will be executed to
retrieve the first scrollable element in page.

Scrollable selectors can accept the `top`, `right`, `bottom` and `left` parameters as deadzone to prevent that edge of the 
container be used as scrollable surface.
Custom views can also be used as scrollable containers with `as_scrollable` command. 
The command marks the last selector as scrollable container.
`driver.view(id: "myCustomScrollableView").as_scrollable(top: 200).page_down`





#### Example 4
```ruby
driver.buttons.scroll_each do |element|
  puts element.text
end
```
The `scroll_each` method is one of the scrollable actions. It will start from the beginning of the scrollable container,
in this case `driver.scrollable`, and find every button in the screen. It will scroll the page until the end of scrollable 
container is reached and all buttons are found.



#### Example 5 (Invalid combination)
```ruby
driver.frame_layout.from_parent.button(text: "My Cool text").siblings
```
This example demonstrates a invalid selector because it cannot be resolved with xpath nor uiautomator strategy.
It will raise StrategyMixException because from_parent selector can only be used with uiautomator strategy and
siblings selector can only be used with xpath strategy.


# Methods 

## Android
### Class Selectors
- element
- elements
- scrollable
- scrollables
- image_view
- image_views
- frame_layout
- frame_layouts
- linear_layout
- linear_layouts
- view
- views
- edit_text
- edit_texts
- view_group
- view_groups
- relative_layout
- relative_layouts
- recycler_view
- recycler_views
- button
- buttons
- image_button
- image_buttons
- horizontal_scroll_view
- horizontal_scroll_views
- scroll_view
- scroll_views
- view_pager
- view_pagers
- check_box
- check_boxes
- list_view
- list_views
- progress_bar
- progress_bars
- radio_button
- radio_buttons
- radio_group
- radio_groups
- search_view
- search_views
- spinner
- spinners
- switch
- switches
- toast
- toasts
- toolbar
- toolbars
- text_view
- text_views
- web_view
- web_views
- card_view
- card_views

Adjacent selectors
- from_parent
- parent
- child
- children
- siblings
- preceding_sibling
- preceding_siblings
- following_sibling
- following_siblings


Element Selector arguments
- id
- long_clickable
- desc
- class
- text
- package
- checkable
- checked
- clickable
- enabled
- focusable
- focused
- index
- selected
- scrollable


- image
- imageMatchThreshold (option for image selector)
- fixImageFindScreenshotDims (option for image selector)
- fixImageTemplateSize (option for image selector)
- fixImageTemplateScale (option for image selector)
- defaultImageTemplateScale (option for image selector)
- checkForImageElementStaleness (option for image selector)
- autoUpdateImageElementPosition (option for image selector)
- imageElementTapStrategy (option for image selector)
- getMatchedImageResult (option for image selector)

### Attributes
- text
- package
- class_name
- checkable?
- checked?
- clickable?
- desc
- enabled?
- focusable?
- focused?
- long_clickable?
- password?
- id
- scrollable?
- selected?
- displayed?
- selection_start
- selection_end
- bounds
- index

# iOS
## Type Selectors 
- element
- elements
- window
- windows
- other
- others
- navigation_bar
- navigation_bars
- button
- buttons
- image
- images
- static_text
- static_texts
- scrollable
- scrollables
- scroll_view
- scroll_views
- table
- tables
- cell
- cells

Adjacent selectors
- parent
- child
- children
- siblings
- preceding_sibling
- preceding_siblings
- following_sibling
- following_siblings

Element Selector arguments
- name, id
- enabled
- type, class
- label
- width
- height
- visible
- value


- image
- imageMatchThreshold (option for image selector)
- fixImageFindScreenshotDims (option for image selector)
- fixImageTemplateSize (option for image selector)
- fixImageTemplateScale (option for image selector)
- defaultImageTemplateScale (option for image selector)
- checkForImageElementStaleness (option for image selector)
- autoUpdateImageElementPosition (option for image selector)
- imageElementTapStrategy (option for image selector)
- getMatchedImageResult (option for image selector)


## Attributes
- accessibility_container
- accessible?
- class_name
- enabled?
- frame
- index
- label, text
- name
- rect, bounds
- selected?
- type
- value
- visible?

# Scroll actions
- scroll_each
- scroll_each_down
- scroll_each_up
- scroll_each_left
- scroll_each_right
- align! (if does not exist, will scroll to find)
- align_top! (if does not exist, will scroll to find)
- align_bottom! (if does not exist, will scroll to find)
- align_left! (if does not exist, will scroll to find)
- align_right! (if does not exist, will scroll to find)
- align
- align_top
- align_bottom
- align_left
- align_right
- scroll_to
- scroll_down_to
- scroll_up_to
- scroll_right_to
- scroll_left_to
- scroll_to_start
- scroll_to_end
- page_down
- page_up
- page_left
- page_right
- fling_down
- fling_up
- fling_left
- fling_right
- drag_to
- drag_by

# Helpers
- as_scrollable
- wait_until_exists
- wait_while_exists
- wait_until
- wait_while
- when_exists
- exists?
- long_tap

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


