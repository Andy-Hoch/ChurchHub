require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  # CORS lets church websites load the self-hosted hub fonts from the launcher.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}", "access-control-allow-origin" => "*" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy,
  # force all access over SSL, use Strict-Transport-Security, and use secure cookies.
  # Only set DISABLE_SSL=1 for trying out the production image without TLS.
  ssl = ENV["DISABLE_SSL"].blank?
  config.assume_ssl = ssl
  config.force_ssl = ssl

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Public address of the hub, used for links in emails and host authorization.
  # ONCE passes BASE_URL (e.g. https://hub.example.com), other setups can set APP_HOST (e.g. hub.example.com).
  public_url = URI(ENV["BASE_URL"]) if ENV["BASE_URL"].present?
  public_url ||= URI("https://#{ENV["APP_HOST"]}") if ENV["APP_HOST"].present?

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options =
    if public_url
      { host: public_url.host, protocol: public_url.scheme, port: (public_url.port unless public_url.port == public_url.default_port) }.compact
    else
      { host: "example.com", protocol: "https" }
    end

  # Outgoing SMTP server, e.g. for form notifications. ONCE passes SMTP_ADDRESS, SMTP_PORT, SMTP_USERNAME,
  # SMTP_PASSWORD and MAILER_FROM_ADDRESS from its email settings. Otherwise add it with bin/rails credentials:edit:
  #   smtp:
  #     address: smtp.example.com
  #     user_name: ...
  #     password: ...
  #     from: hub@example.com
  smtp = if ENV["SMTP_ADDRESS"].present?
    { address: ENV["SMTP_ADDRESS"], port: ENV["SMTP_PORT"], user_name: ENV["SMTP_USERNAME"], password: ENV["SMTP_PASSWORD"] }
  else
    Rails.application.credentials.smtp
  end

  if smtp
    port = smtp[:port].presence&.to_i || 587

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      user_name: smtp[:user_name].presence,
      password: smtp[:password].presence,
      address: smtp[:address],
      port: port,
      tls: port == 465,
      authentication: :plain
    }
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks: with BASE_URL
  # or APP_HOST set, only requests for that domain are answered.
  if public_url
    config.hosts << public_url.host

    # Skip DNS rebinding protection for the default health check endpoint.
    config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
  end
end
