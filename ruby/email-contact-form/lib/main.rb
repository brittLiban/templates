require 'dotenv/load'
require_relative 'utils'
require_relative 'cors'

class EmailContactForm
  def initialize(request, response)
    @request = request
    @response = response
    @utils = Utils.new
    @cors = Cors.new
  end

  def handle
    validate_environment_variables!

    warn_if_open_cors

    case [@request.method, @request.path]
    when ['GET', '/']
      handle_get_request
    when ['POST', '/']
      handle_post_request
    else
      redirect_with_error('invalid-request')
    end
  end

  private

  def validate_environment_variables!
    required_vars = %w[SUBMIT_EMAIL SMTP_HOST SMTP_USERNAME SMTP_PASSWORD]
    missing = required_vars.select { |var| ENV[var].nil? || ENV[var].empty? }
    raise "Missing required fields: #{missing.join(', ')}" unless missing.empty?
  end

  def warn_if_open_cors
    if ENV['ALLOWED_ORIGINS'].nil? || ENV['ALLOWED_ORIGINS'] == '*'
      puts 'WARNING: Allowing requests from any origin - this is a security risk!'
    end
  end

  def handle_get_request
    @response.send_file('static/index.html', content_type: 'text/html; charset=utf-8')
  end

  def handle_post_request
    return redirect_with_error('invalid-request') unless valid_content_type?
    return redirect_with_error('invalid-request') unless @cors.origin_permitted?(@request)

    form_data = parse_form_data
    return redirect_with_error('missing-form-fields') unless form_data['email']

    begin
      send_email(form_data)
      handle_success(form_data)
    rescue => e
      puts "Error: #{e.message}"
      redirect_with_error('server-error')
    end
  end

  def valid_content_type?
    @request.content_type == 'application/x-www-form-urlencoded'
  end

  def send_email(form_data)
    @utils.send_email(
      to: ENV['SUBMIT_EMAIL'],
      from: ENV['SMTP_USERNAME'],
      subject: "New form submission: #{@request.referrer}",
      body: @utils.template_form_message(form_data)
    )
  end

  def handle_success(form_data)
    if form_data['_next']
      redirect_to_next(form_data['_next'])
    else
      @response.send_file('static/success.html', content_type: 'text/html; charset=utf-8')
    end
  end

  def redirect_with_error(error_code)
    @response.redirect(@utils.url_with_code_param(@request.referrer, error_code))
  end

  def redirect_to_next(next_url)
    base_url = URI.parse(@request.referrer).origin
    target_url = URI.join(base_url, next_url).to_s
    puts "Redirecting to #{target_url}"
    @response.redirect(target_url)
  end
end