require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
    options.add_option("goog:loggingPrefs", { browser: "ALL" })
    # Form steps then scroll into place instantly instead of smoothly.
    options.add_argument("--force-prefers-reduced-motion")
  end

  # Shared CI runners can be briefly slow; Capybara's 2s default then fails
  # waits that would have succeeded a moment later. Only failing waits get slower.
  Capybara.default_max_wait_time = 5

  # The embed script is publicly cacheable for a few minutes; without this a
  # test would get the launcher an earlier test loaded for the same hub.
  setup do
    page.driver.browser.execute_cdp("Network.clearBrowserCache")
    browser_console # drop what earlier tests left behind
  end

  # The content security policy is enforced in tests. Anything it blocks
  # (inline styles, scripts without nonce …) shows up in the console.
  teardown do
    violations = browser_console.grep(/Content Security Policy|Refused to/)
    assert_empty violations, "Content Security Policy violations:\n#{violations.join("\n")}"
  end

  def browser_console
    page.driver.browser.logs.get(:browser).map(&:message)
  end

  def sign_in_as(user, password: TEST_PASSWORD)
    visit new_session_path
    fill_in "E-Mail-Adresse", with: user.email_address
    fill_in "Passwort", with: password
    click_on "Anmelden"
  end

  # Turbo marks <html aria-busy> while a visit is still rendering;
  # wait for it before interacting with the new page.
  def wait_for_turbo
    assert_no_selector "html[aria-busy]", visible: :all
  end
end
