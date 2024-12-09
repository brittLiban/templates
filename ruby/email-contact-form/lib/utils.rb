require 'mail'
require 'uri'

class Utils
  def self.get_static_file(filename)
    File.read(File.join(__dir__, 'static', filename))
  rescue Errno::ENOENT
    raise "Static file not found: #{filename}"
  end

  def send_email(options)
    Mail.defaults do
      delivery_method :smtp, {
        address: ENV['SMTP_HOST'],
        port: ENV['SMTP_PORT'] || 587,
        user_name: ENV['SMTP_USERNAME'],
        password: ENV['SMTP_PASSWORD'],
        authentication: 'plain',
        enable_starttls_auto: true
      }
    end

    Mail.new do
      to options[:to]
      from options[:from]
      subject options[:subject]
      body options[:body]
    end.deliver!
  end

  def template_form_message(form_data)
    message_parts = form_data
      .reject { |key, _| key == '_next' }
      .map { |key, value| "#{key}: #{value}" }
    
    "You've received a new message.\n\n#{message_parts.join("\n")}"
  end
end