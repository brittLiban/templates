require 'mail'
require_relative 'cors'
require_relative 'utils'

class EmailHandler
  def initialize(request)
    @request = request
    @utils = Utils.new
    @cors = Cors.new
  end

  def handle_get
    Response.success(Utils.get_static_file('index.html'), 'text/html')
  end

  def handle_post
    validate_environment_variables!
    return Response.error('Invalid content type', 400) unless valid_content_type?
    return Response.error('Invalid origin', 403) unless @cors.origin_permitted?(@request)

    form_data = parse_form_data
    return Response.error('Missing email field', 400) unless form_data['email']

    begin
      send_email(form_data)
      handle_success(form_data)
    rescue => e
      Response.error("Failed to send email: #{e.message}", 500)
    end
  end

  private

  def validate_environment_variables!
    required_vars = %w[SUBMIT_EMAIL SMTP_HOST SMTP_USERNAME SMTP_PASSWORD]
    missing = required_vars.select { |var| ENV[var].nil? || ENV[var].empty? }
    raise "Missing required fields: #{missing.join(', ')}" unless missing.empty?
  end

  def valid_content_type?
    @request.headers['content-type'] == 'application/x-www-form-urlencoded'
  end

  def parse_form_data
    URI.decode_www_form(@request.body).to_h
  end

  def send_email(form_data)
    @utils.send_email(
      to: ENV['SUBMIT_EMAIL'],
      from: ENV['SMTP_USERNAME'],
      subject: "New form submission: #{@request.headers['referer']}",
      body: @utils.template_form_message(form_data)
    )
  end

  def handle_success(form_data)
    if form_data['_next']
      Response.redirect(form_data['_next'])
    else
      Response.success(Utils.get_static_file('success.html'), 'text/html')
    end
  end
end