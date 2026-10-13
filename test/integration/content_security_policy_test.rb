require "test_helper"

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "backend pages allow only their own scripts and styles plus the session's nonce" do
    sign_in_as users(:one)
    get hub_path

    nonce = response.body[/<meta name="csp-nonce" content="([^"]+)"/, 1]
    assert nonce.present?
    assert_match "script-src 'self' 'nonce-#{nonce}'", policy
    assert_match "style-src 'self' 'nonce-#{nonce}'", policy
    assert_match "frame-ancestors 'self'", policy
    assert_match "report-uri /csp-reports", policy
    assert_select "script[type=importmap][nonce=?]", nonce

    get edit_hub_path
    assert_equal nonce, response.body[/<meta name="csp-nonce" content="([^"]+)"/, 1], "Turbo needs the same nonce on every page"
    assert_select "#hub-preview ~ script[nonce=?]", nonce
  end

  test "the public hub page works without nonce and sets no cookie" do
    get public_hub_path(churches(:one).slug)

    assert_response :success
    assert_match "script-src 'self';", policy
    assert_match "style-src 'self' 'unsafe-inline';", policy
    assert_no_match "nonce", policy
    assert_nil response.headers["Set-Cookie"]
  end

  test "the embed endpoints send no policy and set no cookie" do
    get embed_path(hubs(:one).public_token, format: :js)
    assert_nil policy
    assert_nil response.headers["Set-Cookie"]

    post embed_form_submissions_path(hubs(:one).public_token, forms(:prayer)), params: { answers: {} }
    assert_nil policy
    assert_nil response.headers["Set-Cookie"]
  end

  test "the page for outdated browsers keeps its inline styles" do
    get new_session_path, headers: { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36" }

    assert_response :not_acceptable
    assert_nil policy
  end

  private
    def policy
      response.headers["Content-Security-Policy"]
    end
end
