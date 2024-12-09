require 'mail'
require 'dotenv'
require 'uri'
require 'cgi'

def throw_if_missing(obj, keys)
  missing = keys.select { |key| !obj.key?(key) || obj[key].nil? || obj[key].empty? }
  raise "Missing required fields: #{missing.join(', ')}" unless missing.empty?
end

def get_static_file(file_name)
  File.read(File.join(__dir__, '../static', file_name))
end

def template_form_message(form)
  message = "You've received a new message.\n\n"
  form.reject { |key, _| key == '_next' }
      .map { |key, value| "#{key}: #{value}" }
      .join("\n")
  message + form_entries
end

def url_with_code_param(base_url, code_param)
  uri = URI(base_url)
  params = CGI.parse(uri.query || '')
  params['code'] = [code_param]
  uri.query = URI.encode_www_form(params)
  uri.to_s
end

def send_email(options)
  Mail.defaults do
    delivery_method :smtp, {
      address: ENV['SMTP_HOST'],
      port: ENV['SMTP_PORT'] || 587,
      user_name: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD']
    }
  end

  Mail.new do
    to options[:to]
    from options[:from]
    subject options[:subject]
    body options[:text]
  end.deliver!
end