# frozen_string_literal: true

RSpec.describe TestaAppiumDriver do
  it "Android Test" do


    @options = {
        caps: {
            :platformName => "Android",
            :adbPort => 5037,
            :remoteAdbHost => 'localhost',
            :newCommandTimeout => 0, # no timeout when zero
            :adbExecTimeout => 600000,
            :appPackage => "ro.superbet.sport.stage",
            :androidInstallTimeout => 600000,
            :uiautomator2ServerLaunchTimeout => 600000,
            :uiautomator2ServerInstallTimeout => 600000,
            :waitForIdleTimeout => 3000,
            :appWaitPackage => "ro.superbet.sport.stage",
            :deviceName => "Phone",
            :app => "/ruby_apps/hard_storage/project_files/2/apks/bc72173fd9b03e80c58161f2a881c1e679ce368ba9ca79855501597ce2e312ad.apk",
            :noSign => true,
            :udid => "228b371032057ece",
            :automationName => "uiautomator2",
            :systemPort => rand(7000..32000),
            #:noReset => true,
            #:fullReset => false,
            :noReset => false,
            :fullReset => true,
            skipServerInstallation: true,
            :enableMultiWindows => true, # enables appium to see some otherwise "hidden" elements
            #:disableWindowAnimation => true,
            autoGrantPermissions: true,
        },
        appium_lib: {
            #:server_url => "http://localhost:4723/wd/hub/"
            :server_url => "http://10.150.0.56:4723/wd/hub/"
        },
        testa_appium_driver: {
            #default_find_strategy: "xpath",
            #default_scroll_strategy: "w3c",
            scroll_to_find: false
        }
    }


    d = TestaAppiumDriver::Driver.new(@options)

    # d.element(id: "analyticsPositiveView").click
    # d.element(id: "startPlayingLogInView").click
    #
    # d.edit_texts[0].send_keys "testdevice1"
    #
    # d.edit_texts[1].send_keys "superbet1x2"
    #
    # puts "Buttons #{d.buttons(id: "buttonView").count}"
    # d.button(id: "buttonView").click
    #
    d.element(id: "analyticsPositiveView").wait_until_exists(10).click
    d.element(id: "startPlayingRegisterView").click


    inputs = d.edit_texts

    inputs[0].send_keys "aaaabsdfbfd"
    inputs[1].send_keys "aaaa@aaaa.aa"
    inputs[2].send_keys "aaaaaa"
    d.element(id: "buttonView").click

    d.text_view(text: "Județ").scroll_to.click

    puts d.text_view(text: "Bihor").exists?
    d.recycler_view.wait_until_exists
    puts d.element(id: "viewPager").execute.text_view(text: "#soccer").text
    d.text_view(text: "#soccer").preceding_siblings[2]
    d.text_view(text: "#soccer").preceding_siblings.each_with_index do |e, i|
      puts e.class_name
    end
    puts "--------"
    puts d.text_view(text: "#soccer").preceding_sibling.class_name

    puts "=============="
    puts d.text_view(text: "#soccer").following_sibling.className


    d.text_view(text: "Super Extra").scroll_to
    d.text_view(text: "Super Extra").siblings

    puts d.element(id: "viewPager").parent.text_view.text
    d.scrollable.scroll_left_to


    puts d.element(id: "viewPager").list_view.element(id: "nameView").scroll_up_to.text


    puts d.text_view(text: "#soccer").bounds

    d.element(id: "viewPager").elements(id: "nameView").each do |e|
      puts e.text
    end


    expect(TestaAppiumDriver::VERSION).not_to be nil
  end


end
