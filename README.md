# Testa Appium Driver

Testa appium driver is a wrapper around the `ruby_lib_core` driver for appium. 
It leverages all driver features and makes them simple and easy to use. 

There are two key concepts of the testa driver.
- Elements are fetched only when needed
- The Best element fetch / scroll strategy is automatically determined

For more information regarding the key concepts refer to [key concepts](https://github.com/Karazum/testa_appium_driver/key_concepts)
For full api documentation refer to [documentation](https://github.com/Karazum/testa_appium_driver/documentation)




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

### class selectors

#### example 1 
```ruby
driver.linear_layout.button(id: "com.package.name:id/myElementId").click
```
Looks for the first linear layout and a button within the linear layout that has the provided id.
Only 1 find element is executed with the resolved strategy (xpath or uiautomator):<br>
underlying selectors:<br>
xpath: `//android.widget.LinearLayout[1]//android.widget.Button[@resource-id="com.package.name:id/myElementId"]` <br>
uiautomator: `new UiSelector().className("android.widget.LinearLayout").instance(0).childSelector(new UiSelector.className("android.widget.Button").resourceId("com.package.name:id/myElementId")));`<br>

#### example 2
```ruby
driver.linear_layout(id: "myShortIdExample").parent.text_view.text
```
Testa driver converts shorthand ids(that dont have :id/) to full ids
by reading the current package under test and prepending it to the shorthand id. If you don't want to prepend the package
name to the id, use = sign before the id, for example `id: "=idWithoutAPackageName"`.
Because elements are fetched only once needed, we can use the parent, siblings, following and preceding siblings selectors.<br>
Note: parent selector can only be used with the xpath strategy<br>
underlying selectors:<br>
xpath: `//android.widget.LinearLayout[@resource-id="com.package.name:id/myShortIdExample"][1]/../android.widget.TextView[1]` <br>
uiautomator: `exception: parent selector cannot be used with uiautomator strategy`

# example 3
```ruby
driver.list_view(bottom: 200).edit_text(text: "Looking for this text").scroll_to.align!(:bottom).enabled?
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

If the selector chain does not contain a scrollable container, a `driver.scrollabe` command will be executed to
retrieve the first scrollable element in page.

Scrollable selectors can accept the `top`, `right`, `bottom` and `left` parameters as deadzone to prevent that edge of the 
container be used as scrollable surface.
Custom views can also be used as scrollable containers with `as_scrollable` command. 
The command marks the last selector as scrollable container.
`driver.view(id: "myCustomScrollableView").as_scrollable(top: 200).page_down`





# example 4
```ruby
driver.buttons.each do |element|
  puts element.text
end
```
The `each` method is one of the scrollable actions. It will start from the beginning of the scrollable container,
in this case `driver.scrollable`, and find every button in the screen. It will scroll the page until the end of scrollable 
container is reached and all buttons are found.



# example 5
```ruby
driver.frame_layout.from_parent.button(text: "My Cool text").siblings
```
This example demonstrates a invalid selector because it cannot be resovled with xpath nor uiautomator strategy.
It will raise StrategyMixException because from_parent selector can only be used with uiautomator strategy and
siblings selector can only be used with xpath strategy.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


