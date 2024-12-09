require 'mail'

class EmailUtil
  def send_email(form_data)
    configure_smtp
    
    Mail.new do
      to ENV['SUBMIT_EMAIL']
      from ENV['SMTP_USERNAME']
      subject "New form submission"
      body template_form_message(form_data)
    end.deliver!
  end

  private

  def configure_smtp
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
  end

  def template_form_message(form_data)
    message_parts = form_data
      .reject { |key, _| key == '_next' }
      .map { |key, value| "#{key}: #{value}" }
    
    "You've received a new message.\n\n#{message_parts.join("\n")}"
  end
end