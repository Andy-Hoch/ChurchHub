require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Shared CI runners can be briefly slow; Capybara's 2s default then fails
  # waits that would have succeeded a moment later. Only failing waits get slower.
  Capybara.default_max_wait_time = 5

  # The embed script is publicly cacheable for a few minutes; without this a
  # test would get the launcher an earlier test loaded for the same hub.
  setup { page.driver.browser.execute_cdp("Network.clearBrowserCache") }

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
