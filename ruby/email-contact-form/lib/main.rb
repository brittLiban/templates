require 'dotenv'
require 'timeout'
require 'logger'
require_relative 'cors'
require_relative 'utils'

ERROR_CODES = {
  INVALID_REQUEST: 'invalid-request',
  MISSING_FORM_FIELDS: 'missing-form-fields',
  SERVER_ERROR: 'server-error'
}.freeze

def main(context)
  log = context.log.is_a?(Logger) ? context.log : Logger.new(STDOUT)

  req = context.req
  res = context.res

  log.info("Main function started")
  log.info("Headers: #{req.headers.inspect}")
  log.info("Body: #{req.body.inspect}")

  throw_if_missing(ENV, ['SUBMIT_EMAIL', 'SMTP_HOST', 'SMTP_USERNAME', 'SMTP_PASSWORD'])

  unless req.headers['content-type'] == 'application/x-www-form-urlencoded'
    log.error('Incorrect content type.')
    return res.redirect(
      url_with_code_param(req.headers['referer'], ERROR_CODES[:INVALID_REQUEST])
    )
  end

  form = CGI.parse(req.body)
  begin
    throw_if_missing(form, ['email', 'message'])
  rescue StandardError => e
    log.error("Form validation error: #{e.message}")
    return res.redirect(
      url_with_code_param(req.headers['referer'], ERROR_CODES[:MISSING_FORM_FIELDS]),
      301,
      cors_headers(req)
    )
  end

  begin
    send_email(
      to: ENV['SUBMIT_EMAIL'],
      from: ENV['SMTP_USERNAME'],
      subject: "New form submission: #{req.headers['referer']}",
      text: template_form_message(form)
    )
  rescue StandardError => e
    log.error("Email sending failed: #{e.message}")
    return res.redirect(
      url_with_code_param(req.headers['referer'], ERROR_CODES[:SERVER_ERROR]),
      301,
      cors_headers(req)
    )
  end

  if form['_next'].nil? || form['_next'].empty?
    return res.send(
      get_static_file('success.html'),
      200,
      { 'Content-Type' => 'text/html; charset=utf-8' }
    )
  end

  base_url = URI.parse(req.headers['referer'] || 'http://default-url.com').origin
  next_url = URI.join(base_url, form['_next'].first).to_s

  log.info("Redirecting to #{next_url}")

  res.redirect(next_url, 301, cors_headers(req))
end
