require 'dotenv/load'
require 'uri'
require 'cgi'

require_relative 'cors'
require_relative 'utils'

# Error codes
ERROR_CODE = {
  invalid_request: 'invalid-request',
  missing_form_fields: 'missing-form-fields',
  server_error: 'server-error'
}.freeze

# Main function
def handle_request(env, log, error)
  req = Rack::Request.new(env)
  res = Rack::Response.new

  required_env_vars = %w[SUBMIT_EMAIL SMTP_HOST SMTP_USERNAME SMTP_PASSWORD]
  throw_if_missing(ENV, required_env_vars)

  if ENV['ALLOWED_ORIGINS'].nil? || ENV['ALLOWED_ORIGINS'] == '*'
    log.call('WARNING: Allowing requests from any origin - this is a security risk!')
  end

  # Handle root GET request
  if req.request_method == 'GET' && req.path == '/'
    res.write get_static_file('index.html')
    res['Content-Type'] = 'text/html; charset=utf-8'
    return res.finish
  end

  # Validate content type
  unless req.content_type == 'application/x-www-form-urlencoded'
    error.call('Incorrect content type.')
    res.redirect url_with_code_param(req.referer, ERROR_CODE[:invalid_request])
    return res.finish
  end

  # Validate origin
  unless is_origin_permitted(req)
    error.call('Origin not permitted.')
    res.redirect url_with_code_param(req.referer, ERROR_CODE[:invalid_request])
    return res.finish
  end

  # Parse form data
  form = CGI.parse(req.body.read)
  begin
    throw_if_missing(form, ['email'])
  rescue StandardError => e
    res.redirect url_with_code_param(req.referer, e.message), 301
    get_cors_headers(req).each { |key, value| res[key] = value }
    return res.finish
  end

  # Send email
  begin
    send_email(
      to: ENV['SUBMIT_EMAIL'],
      from: ENV['SMTP_USERNAME'],
      subject: "New form submission: #{req.referer}",
      text: template_form_message(form)
    )
  rescue StandardError => e
    error.call(e.message)
    res.redirect url_with_code_param(req.referer, ERROR_CODE[:server_error]), 301
    get_cors_headers(req).each { |key, value| res[key] = value }
    return res.finish
  end

  # Handle next redirect or success page
  if form['_next'].nil? || form['_next'].empty?
    res.write get_static_file('success.html')
    res['Content-Type'] = 'text/html; charset=utf-8'
    return res.finish
  end

  base_url = URI(req.referer).origin
  next_url = URI.join(base_url, form['_next'].first).to_s
  log.call("Redirecting to #{next_url}")

  res.redirect next_url, 301
  get_cors_headers(req).each { |key, value| res[key] = value }
  res.finish
end