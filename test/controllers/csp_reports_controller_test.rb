require "test_helper"

class CspReportsControllerTest < ActionDispatch::IntegrationTest
  def report(body)
    post csp_reports_path, params: body, headers: { "Content-Type" => "application/csp-report" }
  end

  test "logs violations without query strings" do
    logged = capture_log do
      report({ "csp-report" => {
        "document-uri" => "https://hub.example/hub/edit?token=geheim",
        "violated-directive" => "style-src-attr",
        "blocked-uri" => "inline"
      } }.to_json)
    end

    assert_response :no_content
    assert_match "CSP violation: style-src-attr blocked inline on https://hub.example/hub/edit", logged
    assert_no_match "geheim", logged
    assert_nil response.headers["Set-Cookie"]
  end

  test "ignores reports it cannot read" do
    [ "kaputt", "[]", { "csp-report" => "x" }.to_json ].each do |body|
      assert_no_match "CSP violation", capture_log { report(body) }
      assert_response :no_content
    end
  end

  private
    def capture_log
      output = StringIO.new
      original = Rails.logger
      Rails.logger = ActiveSupport::Logger.new(output)
      ActionController::Base.logger = Rails.logger
      yield
      output.string
    ensure
      Rails.logger = original
      ActionController::Base.logger = original
    end
end
