require 'dotenv'
require_relative 'cors'
require_relative 'utils'

ERROR_CODES = {
  INVALID_REQUEST: 'invalid-request',
  MISSING_FORM_FIELDS: 'missing-form-fields',
  SERVER_ERROR: 'server-error'
}.freeze

def main(context)
  req = context.req
  res = context.res
  log = context.log

  log.info("Request body: #{req.body}")
  
  throw_if_missing(ENV, [
    'SUBMIT_EMAIL',
    'SMTP_HOST',
    'SMTP_USERNAME',
    'SMTP_PASSWORD'
  ])

  


  if ENV['ALLOWED_ORIGINS'].nil? || ENV['ALLOWED_ORIGINS'] == '*'
    log.warn('WARNING: Allowing requests from any origin - this is a security risk!')
  end

  if req.method == 'GET' && req.path == '/'
    return res.send(
      get_static_file('index.html'),
      200,
      { 'Content-Type' => 'text/html; charset=utf-8' }
    )
  end

  unless req.headers['content-type'] == 'application/x-www-form-urlencoded'
    context.error('Incorrect content type.')
    return res.redirect(
      url_with_code_param(req.headers['referer'], ERROR_CODES[:INVALID_REQUEST])
    )
  end

  unless origin_permitted?(req)
    context.error('Origin not permitted.')
    return res.redirect(
      url_with_code_param(req.headers['referer'], ERROR_CODES[:INVALID_REQUEST])
    )
  end

  form = CGI.parse(req.body)
  begin
    throw_if_missing(form, ['email'])
  rescue StandardError => e
    return res.redirect(
      url_with_code_param(req.headers['referer'], e.message),
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
    context.error(e.message)
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

  base_url = URI.parse(req.headers['referer']).origin
  next_url = URI.join(base_url, form['_next'].first).to_s

  log.info("Redirecting to #{next_url}")

  res.redirect(next_url, 301, cors_headers(req))
end
