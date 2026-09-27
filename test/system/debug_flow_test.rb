require "application_system_test_case"

# TEMPORARY: diagnoses the flaky system test on CI. Not meant to be merged.
class DebugFlowTest < ApplicationSystemTestCase
  PROBE = <<~JS
    (() => {
      const t0 = Date.now();
      const push = (msg) => {
        const log = JSON.parse(sessionStorage.getItem("__dbg") || "[]");
        log.push((Date.now() % 100000) + " " + msg);
        sessionStorage.setItem("__dbg", JSON.stringify(log));
      };
      window.__mark = push;
      push("NEW DOCUMENT " + location.pathname);
      const describe = (el) => el && el.tagName ? (el.tagName + (el.name ? "[" + el.name + "]" : "") + " '" + (el.textContent || "").trim().slice(0, 25) + "'") : String(el);
      ["turbo:click", "turbo:before-visit", "turbo:visit", "turbo:submit-start", "turbo:submit-end",
       "turbo:before-render", "turbo:render", "turbo:load", "turbo:before-prefetch", "turbo:reload",
       "turbo:before-cache", "turbo:fetch-request-error"].forEach((name) =>
        document.addEventListener(name, (e) => push(name + " " + (e.detail?.url || e.detail?.reason || "") + (e.detail?.renderMethod ? " " + e.detail.renderMethod : "") + (e.detail?.isPreview ? " PREVIEW" : ""))));
      document.addEventListener("turbo:before-fetch-request", (e) => {
        const h = e.detail.fetchOptions.headers || {};
        push("fetch " + (e.detail.fetchOptions.method || "GET") + " " + e.detail.url + (h["X-Sec-Purpose"] ? " PREFETCH" : ""));
      });
      document.addEventListener("turbo:before-fetch-response", (e) => push("response " + e.detail.fetchResponse.response.status + " " + e.detail.fetchResponse.response.url));
      ["pointerdown", "mousedown", "click"].forEach((name) =>
        document.addEventListener(name, (e) => push(name + " on " + describe(e.target) + " trusted=" + e.isTrusted), true));
      document.addEventListener("mouseover", (e) => { if (e.target.closest && e.target.closest("a")) push("mouseover link " + describe(e.target.closest("a"))); }, true);
      document.addEventListener("input", (e) => push("input " + describe(e.target) + " len=" + e.target.value.length), true);
      document.addEventListener("focusin", (e) => push("focus " + describe(e.target)), true);
      document.addEventListener("invalid", (e) => push("INVALID " + describe(e.target)), true);
      window.addEventListener("pagehide", () => push("PAGEHIDE"));
      window.addEventListener("DOMContentLoaded", () => push("DOMContentLoaded"));
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
    @steps = []
  end

  teardown do
    ActiveSupport::Notifications.unsubscribe(@subscriber)
    Capybara.current_session.quit # every flow starts with a fresh Chrome, like the real test on CI
  end

  def browser_state
    state = page.evaluate_script("[document.hasFocus(), document.visibilityState, document.readyState]") rescue [ "?" ]
    targets = page.driver.browser.execute_cdp("Target.getTargets")["targetInfos"].map { "#{_1["type"]}:#{_1["url"][0, 40]}#{" ATTACHED" if _1["attached"]}" } rescue [ "?" ]
    "focus=#{state[0]} visibility=#{state[1]} ready=#{state[2]} windows=#{page.driver.browser.window_handles.size} targets=#{targets.inspect}"
  end

  def step(name)
    @steps << "  [#{name}] #{browser_state}"
    started = Time.now
    page.execute_script("window.__mark && window.__mark(#{("--- TEST: " + name).to_json})") rescue nil
    yield
    @steps << "#{name}: #{((Time.now - started) * 1000).round}ms"
  end

  def dump(outcome)
    browser_log = JSON.parse(page.evaluate_script("sessionStorage.getItem('__dbg')") || "[]") rescue [ "(could not read log)" ]
    puts "\n######## #{name} => #{outcome}"
    puts "chrome #{page.driver.browser.capabilities.browser_version}"
    puts "steps:", @steps.map { "  #{_1}" }
    puts "server:", @requests.map { "  #{_1}" }
    condensed = browser_log.chunk_while { |a, b| a[/input .*len=/] && a.split(" ")[1..2] == b.split(" ")[1..2] }
      .map { |group| group.size > 1 ? "#{group.first} .. #{group.last[/len=\d+/]} (#{group.size} events)" : group.first }
    puts "browser:", condensed.map { "  #{_1}" }
  end

  20.times do |i|
    test "flow_#{i}" do
      step("visit login") { visit new_session_path; assert_field "E-Mail-Adresse" }
      step("fill login") do
        fill_in "E-Mail-Adresse", with: users(:one).email_address
        fill_in "Passwort", with: "password"
      end
      step("submit login") { click_on "Anmelden"; assert_selector "h1", text: "Links", wait: 10 }
      step("click Link hinzufuegen") do
        click_on "Link hinzufügen"
        if has_selector?("h1", text: "Neuer Link", wait: 2)
          @steps << "  navigation within 2s"
        elsif has_selector?("h1", text: "Neuer Link", wait: 8)
          @steps << "  SLOW: navigation only after >2s"
        else
          @steps << "  LOST: no navigation within 10s"
          flunk "click on Link hinzufuegen had no effect"
        end
      end
      step("fill title") { fill_in "Titel", with: "Spenden" }
      step("fill url") { fill_in "Adresse (URL)", with: "https://example.com/spenden" }
      step("values right after fill") do
        @steps << "  title=#{find_field("Titel").value.inspect} url=#{find_field("Adresse (URL)").value.inspect}"
      end
      sleep 1
      step("values 1s later") do
        @steps << "  title=#{find_field("Titel").value.inspect} url=#{find_field("Adresse (URL)").value.inspect}"
      end
      step("save") { click_on "Speichern"; assert_text "Link hinzugefügt.", wait: 10 }
      dump(@steps.any? { _1.include?("SLOW") || _1.include?('title=""') } ? "OK-BUT-SUSPICIOUS" : "OK")
    rescue Minitest::Assertion, Capybara::CapybaraError, Selenium::WebDriver::Error::WebDriverError => e
      @steps << "FAILED: #{e.class}: #{e.message.lines.first.strip}"
      dump("FAIL")
      raise
    end
  end
end
