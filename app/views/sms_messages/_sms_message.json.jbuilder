json.extract! sms_message, :id, :to, :body, :customer_id, :caddy_id, :created_at, :updated_at
json.url sms_message_url(sms_message, format: :json)