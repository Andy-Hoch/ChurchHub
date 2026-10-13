# Receives the browsers' reports about content security policy violations
# (report-uri in config/initializers/content_security_policy.rb) and writes
# them to the log. Only paths are logged: query strings can hold tokens.
class CspReportsController < ActionController::Base
  skip_forgery_protection
  content_security_policy false

  rate_limit to: 30, within: 1.minute, with: -> { head :too_many_requests }

  def create
    report = parsed_report
    if report
      logger.warn "CSP violation: #{report["violated-directive"]} blocked #{without_query(report["blocked-uri"])} on #{without_query(report["document-uri"])}"
    end

    head :no_content
  end

  private
    def parsed_report
      report = JSON.parse(request.raw_post)["csp-report"]
      report if report.is_a?(Hash)
    rescue JSON::ParserError, TypeError
      nil
    end

    def without_query(uri)
      uri.to_s.split(/[?#]/).first.to_s.truncate(200)
    end
end
