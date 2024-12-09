require 'mail'
require_relative '../utils/cors'
require_relative '../utils/email'
require_relative '../utils/file_helper'
require_relative '../utils/response'

class EmailHandler
  def initialize(request)
    @request = request
    @email_util = EmailUtil.new
    @cors = Cors.new
  end

  def handle_get
    begin
      content = FileHelper.get_static_file('index.html')
      Response.success(content, 'text/html; charset=utf-8')
    rescue => e
      puts "Error reading file: #{e.message}"
      Response.error('File not found', 404)
    end
  end

  def handle_post
    validate_environment_variables!
    return Response.error('Invalid content type', 400) unless valid_content_type?
    return Response.error('Invalid origin', 403) unless @cors.origin_permitted?(@request)

    form_data = parse_form_data
    return Response.error('Missing email field', 400) unless form_data['email']

    begin
      @email_util.send_email(form_data)
      handle_success(form_data)
    rescue => e
      puts "Error sending email: #{e.message}"
      Response.error("Failed to send email", 500)
    end
  end

  def handle_options
    Response.success('', 'text/plain', 204)
  end

  private

  def validate_environment_variables!
    required_vars = %w[SUBMIT_EMAIL SMTP_HOST SMTP_USERNAME SMTP_PASSWORD]
    missing = required_vars.select { |var| ENV[var].nil? || ENV[var].empty? }
    raise "Missing required fields: #{missing.join(', ')}" unless missing.empty?
  end

  def valid_content_type?
    @request.headers['content-type'].to_s.include?('application/x-www-form-urlencoded')
  end

  def parse_form_data
    URI.decode_www_form(@request.body.to_s).to_h
  end

  def handle_success(form_data)
    if form_data['_next']
      Response.redirect(form_data['_next'])
    else
      Response.success(FileHelper.get_static_file('success.html'), 'text/html; charset=utf-8')
    end
  end
end