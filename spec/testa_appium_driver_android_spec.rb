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
            #waitForSelectorTimeout: 26,
            :waitForIdleTimeout => 1,
            :appWaitPackage => "ro.superbet.sport.stage",
            :deviceName => "Phone",
            :app => "/ruby_apps/hard_storage/project_files/2/apks/bc72173fd9b03e80c58161f2a881c1e679ce368ba9ca79855501597ce2e312ad.apk",
            :noSign => true,
            :udid => "228b371032057ece",
            :automationName => "uiautomator2",
            :systemPort => rand(7000..32000),
            :noReset => true,
            :fullReset => false,
            # :noReset => false,
            # :fullReset => true,
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


    puts "aaa"

    drag_handle = d.frame_layout(id: "defaultBetSlipView").linear_layout.view
    puts drag_handle.bounds
    drag_handle.wait_until_exists.drag_up_by(1000)
    sleep 1

    scrollable = d.element(id: "betSlipFragmentHolder").recycler_view(id:"recyclerView")
    scrollable.elements(id: "match_holder").parent.each_down do |m|
      puts "1"
      name1 = m.element(id: "match_team1Name").text
      name2 = m.element(id: "match_team2Name").text
      market = m.element(id: "betOfferName").text
      puts "name: #{name1} - #{name2}, market_name: #{market}"
    end




    d.element(id: "buttonView").click

    d.text_view(text: "Jude??").scroll_to.click

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
