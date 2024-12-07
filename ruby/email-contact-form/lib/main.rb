require 'dotenv/load'
require 'cgi'
require 'uri'
require_relative 'cors'
require_relative 'utils'

# Error codes
ErrorCode = {
  INVALID_REQUEST: 'invalid-request',
  MISSING_FORM_FIELDS: 'missing-form-fields',
  SERVER_ERROR: 'server-error'
}.freeze

def handle_request(req, res, log, error)
  throw_if_missing(ENV, %w[SUBMIT_EMAIL SMTP_HOST SMTP_USERNAME SMTP_PASSWORD])

  if ENV['ALLOWED_ORIGINS'].nil? || ENV['ALLOWED_ORIGINS'] == '*'
    log.call('WARNING: Allowing requests from any origin - this is a security risk!')
  end

  if req[:method] == 'GET' && req[:path] == '/'
    res[:text] = get_static_file('index.html')
    res[:status] = 200
    res[:headers] = { 'Content-Type' => 'text/html; charset=utf-8' }
    return res
  end

  if req[:headers]['content-type'] != 'application/x-www-form-urlencoded'
    error.call('Incorrect content type.')
    res[:redirect] = url_with_code_param(req[:headers]['referer'], ErrorCode[:INVALID_REQUEST])
    return res
  end

  unless is_origin_permitted(req)
    error.call('Origin not permitted.')
    res[:redirect] = url_with_code_param(req[:headers]['referer'], ErrorCode[:INVALID_REQUEST])
    return res
  end

  form = CGI.parse(req[:body] || '')
  begin
    throw_if_missing(form, ['email'])
  rescue StandardError => e
    res[:redirect] = url_with_code_param(req[:headers]['referer'], e.message)
    res[:status] = 301
    res[:headers] = get_cors_headers(req)
    return res
  end

  begin
    send_email(
      to: ENV['SUBMIT_EMAIL'],
      from: ENV['SMTP_USERNAME'],
      subject: "New form submission: #{req[:headers]['referer']}",
      text: template_form_message(form)
    )
  rescue StandardError => e
    error.call(e.message)
    res[:redirect] = url_with_code_param(req[:headers]['referer'], ErrorCode[:SERVER_ERROR])
    res[:status] = 301
    res[:headers] = get_cors_headers(req)
    return res
  end

  if form['_next'].nil? || form['_next'].first.empty?
    res[:text] = get_static_file('success.html')
    res[:status] = 200
    res[:headers] = { 'Content-Type' => 'text/html; charset=utf-8' }
  else
    base_url = URI(req[:headers]['referer']).origin
    redirect_url = URI.join(base_url, form['_next'].first).to_s
    log.call("Redirecting to #{redirect_url}")
    res[:redirect] = redirect_url
    res[:status] = 301
    res[:headers] = get_cors_headers(req)
  end

  res
end