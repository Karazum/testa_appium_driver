# frozen_string_literal: true

RSpec.describe TestaAppiumDriver do
  it "iOS Test" do
    require 'em/pure_ruby'
    require 'appium_lib_core'
    require 'net/http'

    udid = "d4b893ee622bf59795eeaa7d2c36bcca05fcccb1"

    #testa sends ingredients for remote quamotion to get app
    path = "project_files/2/apks/5df912ca31070c6d70104b997a611c58274f92a0af0f2436944fea3db1c10822.ipa"
    ipa_url = "https://supertesta.com/ipas/#{path}"
    ipa_name = File.basename(path)

    #quamotion endpoint that can receive ipa url, and download it
    url = "http://10.150.0.56:9494/receive_ipa?udid=#{udid}&ipa_url=#{ipa_url}&ipa_name=#{ipa_name}"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    res = http.request(request)
    raise "copy opa res code not 200 : #{res.code}" unless res.code == "200"
    ipa_remote_path = res.body


    start_vnc_url = "http://10.150.0.56:9494/start_vnc_server?udid=#{udid}"
    uri = URI("#{start_vnc_url}")
    res = Net::HTTP.start(uri.host, uri.port, read_timeout: 129) do |http|
      http.max_retries = 0 # Fix http retries
      http.request(Net::HTTP::Post.new(uri))
    end
    urls = JSON.parse(res.body)
    wda_url = URI("#{urls['wda_url']}")
    wda_port = wda_url.port


    @options = {
        caps: {
            :platformName => "iOS",
            :newCommandTimeout => 0, # no timeout when zero
            :platformVersion => "14.4",
            :bundleId => "ro.superbet.sport.stage",
            :waitForIdleTimeout => 3000,
            :deviceName => 'iphone',
            :app => ipa_remote_path,
            :webDriverAgentUrl => "http://127.0.0.1:#{wda_port}",
            :automationName => "XCUITest",
            :noSign => true,
            :udid => udid, # iPhone 7 black


            :systemPort => rand(7000..32000),
            :noReset => true,
            :fullReset => false,
            :enableMultiWindows => true, # enables appium to see some otherwise "hidden" elements
            #:disableWindowAnimation => true,
            autoGrantPermissions: true,
        },
        appium_lib: {
            #:server_url => "http://localhost:4723/wd/hub/"
            :server_url => "http://10.150.0.56:4725/wd/hub/"
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
    # sleep 10


    puts d.static_text(text: "#soccer").wait_until_exists.text
    d.element(text: "Super Extra").scroll_to
    puts d.static_text(text: "#soccer").class_name
    puts d.static_text(text: "#soccer").parent.class_name

    d.text_view(text: "#soccer").preceding_siblings.each_with_index do |e, i|
      puts d.text_view(text: "#soccer").preceding_siblings[i].className
      puts e.className
    end
    puts "--------"
    puts d.text_view(text: "#soccer").preceding_sibling.className

    puts "=============="
    puts d.text_view(text: "#soccer").following_sibling.className


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
