require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  def sign_in_as(user, password: "password")
    visit new_session_path
    fill_in "E-Mail-Adresse", with: user.email_address
    fill_in "Passwort", with: password
    click_on "Anmelden"
  end

  # Turbo marks <html aria-busy> while a visit (including a hover prefetch)
  # is still rendering; filling a form before that finishes can get wiped.
  def wait_for_turbo
    assert_no_selector "html[aria-busy]", visible: :all
  end
end
