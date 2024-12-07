require 'webrick'
require 'dotenv/load'
require 'cgi'
require_relative 'cors'
require_relative 'utils'

# Error codes
ErrorCode = {
  INVALID_REQUEST: 'invalid-request',
  MISSING_FORM_FIELDS: 'missing-form-fields',
  SERVER_ERROR: 'server-error'
}.freeze

class FormHandler < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    check_environment_variables
    
    response.content_type = 'text/html'
    response.body = get_static_file('index.html')
  end

  def do_POST(request, response)
    check_environment_variables
    
    unless request.content_type == 'application/x-www-form-urlencoded'
      response.status = 400
      response.body = 'Incorrect content type.'
      return
    end

    unless is_origin_permitted(request)
      response.status = 403
      response.body = 'Origin not permitted.'
      return
    end

    form = CGI.parse(request.body).transform_values(&:first)
    
    begin
      throw_if_missing(form, ['email'])
    rescue StandardError => e
      redirect(response, url_with_code_param(request.header['referer'], e.message))
      return
    end

    begin
      send_email(
        to: ENV['SUBMIT_EMAIL'],
        from: ENV['SMTP_USERNAME'],
        subject: "New form submission: #{request.header['referer']}",
        text: template_form_message(form)
      )
    rescue StandardError => e
      puts "Error: #{e.message}"
      redirect(response, url_with_code_param(request.header['referer'], ErrorCode[:SERVER_ERROR]))
      return
    end

    if form['_next'].nil? || form['_next'].empty?
      response.content_type = 'text/html'
      response.body = get_static_file('success.html')
    else
      base_url = URI(request.header['referer']).origin
      redirect_url = URI.join(base_url, form['_next']).to_s
      puts "Redirecting to #{redirect_url}"
      redirect(response, redirect_url)
    end
  end

  private

  def check_environment_variables
    throw_if_missing(ENV, %w[SUBMIT_EMAIL SMTP_HOST SMTP_USERNAME SMTP_PASSWORD])
    if ENV['ALLOWED_ORIGINS'].nil? || ENV['ALLOWED_ORIGINS'] == '*'
      puts 'WARNING: Allowing requests from any origin - this is a security risk!'
    end
  end

  def redirect(response, url)
    response.status = 301
    response['Location'] = url
    cors_headers = get_cors_headers(request)
    cors_headers.each { |key, value| response[key] = value }
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount '/', FormHandler
trap('INT') { server.shutdown }
server.start