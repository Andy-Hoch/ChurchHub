require "application_system_test_case"

# TEMPORARY: diagnoses the flaky system test on CI. Not meant to be merged.
# Runs the unchanged LinksTest flow many times, each in a fresh Chrome. The probe
# only records passively (no JS round-trips between steps) and is read on failure.
class DebugFlowTest < ApplicationSystemTestCase
  PROBE = <<~JS
    (() => {
      const log = JSON.parse(sessionStorage.getItem("__dbg") || "[]");
      window.__dbg = log;
      const push = (msg) => log.push((Date.now() % 100000) + " " + msg);
      window.addEventListener("pagehide", () => { push("PAGEHIDE"); sessionStorage.setItem("__dbg", JSON.stringify(log)); });
      push("NEW DOCUMENT " + location.pathname);
      const describe = (el) => el && el.tagName ? (el.tagName + (el.name ? "[" + el.name + "]" : "") + " '" + (el.textContent || "").trim().slice(0, 25) + "'") : String(el);
      ["turbo:click", "turbo:before-visit", "turbo:visit", "turbo:submit-start", "turbo:submit-end",
       "turbo:before-render", "turbo:render", "turbo:load", "turbo:before-prefetch", "turbo:reload",
       "turbo:fetch-request-error"].forEach((name) =>
        document.addEventListener(name, (e) => push(name + " " + (e.detail?.url || e.detail?.reason || "") + (e.detail?.renderMethod ? " " + e.detail.renderMethod : "") + (e.detail?.isPreview ? " PREVIEW" : ""))));
      document.addEventListener("turbo:before-fetch-response", (e) => push("response " + e.detail.fetchResponse.response.status + " " + e.detail.fetchResponse.response.url));
      ["pointerdown", "click", "keydown"].forEach((name) =>
        document.addEventListener(name, (e) => { if (name !== "keydown" || !window.__lastKey || window.__lastKey !== e.target) push(name + " on " + describe(e.target)); window.__lastKey = name === "keydown" ? e.target : null; }, true));
      document.addEventListener("focusin", (e) => push("focus " + describe(e.target)), true);
      document.addEventListener("invalid", (e) => push("INVALID " + describe(e.target)), true);
      document.addEventListener("visibilitychange", () => push("visibility " + document.visibilityState));
      window.addEventListener("blur", () => push("WINDOW BLUR"));
      window.addEventListener("focus", () => push("WINDOW FOCUS"));
    })();
  JS

  setup do
    @requests = []
    @subscriber = ActiveSupport::Notifications.subscribe("process_action.action_controller") do |event|
      p = event.payload
      prefetch = p[:headers] && p[:headers]["X-Sec-Purpose"].present?
      @requests << "#{p[:method]} #{p[:path]} -> #{p[:status]} #{event.duration.round}ms#{" PREFETCH" if prefetch} #{p[:controller]}##{p[:action]}"
    end
    page.driver.browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: PROBE)
  end

  teardown do
    ActiveSupport::Notifications.unsubscribe(@subscriber)
    Capybara.current_session.quit # every flow starts with a fresh Chrome, like the real test on CI
  end

  def dump(error)
    log = page.evaluate_script("window.__dbg") rescue [ "(could not read log)" ]
    puts "\n######## #{name} => FAIL: #{error.message.lines.first.strip}"
    puts "chrome #{page.driver.browser.capabilities.browser_version} path=#{current_path}"
    puts "server:", @requests.map { "  #{_1}" }
    puts "browser:", Array(log).map { "  #{_1}" }
  end

  30.times do |i|
    test "real_flow_#{i}" do
      sign_in_as users(:one)
      assert_selector "h1", text: "Links"

      click_on "Link hinzufügen"
      assert_selector "h1", text: "Neuer Link"
      wait_for_turbo

      fill_in "Titel", with: "Spenden"
      fill_in "Adresse (URL)", with: "https://example.com/spenden"
      assert_field "Titel", with: "Spenden"
      click_on "Speichern"

      assert_text "Link hinzugefügt."
      assert_selector "h1", text: "Links"
      assert_text "Spenden"

      visit public_hub_path(churches(:one).slug)
      assert_selector "h1", text: "Gemeinde Eins"
      assert_text "Spenden"
      assert_text "Gottesdienst live"
      assert_no_text "Intern"
      puts "######## #{name} => OK"
    rescue Minitest::Assertion, Capybara::CapybaraError, Selenium::WebDriver::Error::WebDriverError => e
      dump(e)
      raise
    end
  end
end
