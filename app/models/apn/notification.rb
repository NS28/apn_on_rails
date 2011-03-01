# Represents the message you wish to send. 
# An APN::Notification belongs to an APN::Device.
# 
# Example:
#   apn = APN::Notification.new
#   apn.badge = 5
#   apn.sound = 'my_sound.aiff'
#   apn.alert = 'Hello!'
#   apn.device = APN::Device.find(1)
#   apn.save
# 
# To deliver call the following method:
#   APN::Notification.send_notifications
# 
# As each APN::Notification is sent the <tt>sent_at</tt> column will be timestamped,
# so as to not be sent again.
class APN::Notification < APN::Base
  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper
  serialize :custom_properties

  ERROR_RESPONSE_STATUS_CODES = {
    0 => :no_errors_encountered,
    1 => :processing_error,
    2 => :missing_device_token,
    3 => :missing_topic,
    4 => :missing_payload,
    5 => :invalid_token_size,
    6 => :invalid_topic_size,
    7 => :invalid_payload_size,
    8 => :invalid_token,
    255 => :unknown
  }

  # TODO: add a expires_at timestamp field, do a before save that sets it to EXPIRY_DAYS from now.  Also, make
  # EXPIRY_DAYS configurable
  EXPIRY_DAYS = 30
  
  belongs_to :device, :class_name => 'APN::Device'
  has_one    :app,    :class_name => 'APN::App', :through => :device
  
  # returns a more or less human readable version of the error_response_status_code
  def status
    if error_response_status_code?
      if ERROR_RESPONSE_STATUS_CODES.keys.include?(error_response_status_code) 
        ERROR_RESPONSE_STATUS_CODES[error_response_status_code]
      else
        :other
      end
    else
      :ok
    end
  end

  # Stores the text alert message you want to send to the device.
  # 
  # If the message is over 150 characters long it will get truncated
  # to 150 characters with a <tt>...</tt>
  def alert=(message)
    if !message.blank? && message.size > 150
      message = truncate(message, :length => 150)
    end
    write_attribute('alert', message)
  end
  
  # Creates a Hash that will be the payload of an APN.
  # 
  # Example:
  #   apn = APN::Notification.new
  #   apn.badge = 5
  #   apn.sound = 'my_sound.aiff'
  #   apn.alert = 'Hello!'
  #   apn.apple_hash # => {"aps" => {"badge" => 5, "sound" => "my_sound.aiff", "alert" => "Hello!"}}
  #
  # Example 2: 
  #   apn = APN::Notification.new
  #   apn.badge = 0
  #   apn.sound = true
  #   apn.custom_properties = {"typ" => 1}
  #   apn.apple_hash # => {"aps" => {"badge" => 0, "sound" => "1.aiff"}, "typ" => "1"}
  def apple_hash
    result = {}
    result['aps'] = {}
    result['aps']['alert'] = self.alert if self.alert
    result['aps']['badge'] = self.badge.to_i if self.badge
    if self.sound
      result['aps']['sound'] = self.sound if self.sound.is_a? String
      result['aps']['sound'] = "1.aiff" if self.sound.is_a?(TrueClass)
    end
    if self.custom_properties
      self.custom_properties.each do |key,value|
        result["#{key}"] = "#{value}"
      end
    end
    result
  end
  
  # Creates the JSON string required for an APN message.
  # 
  # Example:
  #   apn = APN::Notification.new
  #   apn.badge = 5
  #   apn.sound = 'my_sound.aiff'
  #   apn.alert = 'Hello!'
  #   apn.to_apple_json # => '{"aps":{"badge":5,"sound":"my_sound.aiff","alert":"Hello!"}}'
  def to_apple_json
    self.apple_hash.to_json
  end
  
  # Creates the binary message needed to send to Apple, in the 'enhanced notification format'.
  #
  # The format is documented at:
  # http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingWIthAPS/CommunicatingWIthAPS.html
  def message_for_sending
    json = self.to_apple_json
    raise APN::Errors::ExceededMessageSizeError.new(alert) if alert.size.to_i > 256
    [1, self.id, EXPIRY_DAYS.days.from_now.to_i, 0, 32, self.device.token.delete(' '), 0, json.length, json].pack('ciiccH*cca*')
  end
  
  def self.send_notifications
    ActiveSupport::Deprecation.warn("The method APN::Notification.send_notifications is deprecated.  Use APN::App.send_notifications instead.")
    APN::App.send_notifications
  end
  
end # APN::Notification
