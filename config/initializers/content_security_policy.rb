# Be sure to restart your server when you modify this file.

# Only this app's own scripts, styles, fonts and images, plus inline scripts
# and styles that carry the per-session nonce. The public hub page relaxes
# styles (see PublicHubsController); the embed endpoints send no policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src :self
    policy.style_src :self
    policy.img_src :self
    policy.font_src :self
    policy.connect_src :self
    policy.object_src :none
    policy.base_uri :self
    policy.form_action :self
    policy.frame_ancestors :self
    policy.report_uri "/csp-reports"
  end

  # The nonce has to stay the same across Turbo visits, because the page keeps
  # the policy of its first load. So it is created once per session and kept
  # there. Only the backend (ApplicationController) gets one: public pages and
  # the launcher must never touch the session or set a cookie.
  config.content_security_policy_nonce_generator = ->(request) do
    if request.controller_instance.is_a?(ApplicationController)
      request.session[:content_security_policy_nonce] ||= SecureRandom.base64(16)
    end
  end
  config.content_security_policy_nonce_directives = %w[ script-src style-src ]

  # Only report violations for now. Tests always enforce the policy, so that
  # switching it on later doesn't break anything; CSP_ENFORCE=1 does the same.
  config.content_security_policy_report_only = !(Rails.env.test? || ENV["CSP_ENFORCE"].present?)
end
