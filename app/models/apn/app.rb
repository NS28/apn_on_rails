require 'apn/connection'
require 'apn/feedback'
require 'apn/errors'

class APN::App < APN::Base
  has_many :groups, :class_name => 'APN::Group', :dependent => :destroy
  has_many :devices, :class_name => 'APN::Device', :dependent => :destroy
  has_many :notifications, :through => :devices, :dependent => :destroy
  has_many :unsent_notifications, :through => :devices
  has_many :group_notifications, :through => :groups
  has_many :unsent_group_notifications, :through => :groups
    
  def cert
    (Rails.env == 'production' ? apn_prod_cert : apn_dev_cert)
  end
  
  def self.send_notifications
    APN::App.find_each &:send_notifications
  end
  
  # Opens a connection to the Apple APN server and attempts to batch deliver unsent notifications (Group or Single)
  # 
  # As each notification is sent the <tt>sent_at</tt> column will be timestamped,
  # so as to not be sent again.
  # 
  def send_notifications(recursions = 0)
    # return if self.unsent_notifications.nil? || self.unsent_notifications.empty?
    raise ArgumentError, 'infinite recursion' if recursions > self.notifications.count

    failed_notification_id = nil
    checked_for_apns_errors = false
    sent_noty_ids = []

    APN::Connection.open_for_delivery({:cert => cert}) do |conn, sock|
      self.devices.find_each do |dev|
        dev.unsent_notifications.each do |noty|

          # We start out being optimistic that this noty will be sent.
          # This also helps us to backtrack when we get an error and have to resend notys after the one that failed.
          noty.update_attribute(:sent_at, Time.now)
          sent_noty_ids << noty.id

          begin
            response = conn.write(noty.message_for_sending)
          rescue => e
            failed_notification_id = check_for_apns_error(conn)
            checked_for_apns_errors = true
            break
          end

        end

        unless checked_for_apns_errors
          failed_notification_id = check_for_apns_error(conn)
        end

        unless failed_notification_id.nil?
          unsend_notifications_sent_after_failure(failed_notification_id, sent_noty_ids)
          send_notifications(recursions + 1)
        end
      end
    end
  end

  def check_for_apns_error(conn)
    response = nil
    noty_id = nil

    if IO.select([conn], nil, nil, 1)
      response = conn.read(6)
    end

    unless response.nil?
      command, status_code, noty_id = response.unpack('cci')
      #logger.debug("APNS Error Response:  c #{command} sc #{status_code} i #{noty_id}")
      # TODO: add an apns_error field to notifications, store the status code there.
    end

    noty_id
  end

  def self.unsend_notifications_sent_after_failure(failed_notification_id, sent_noty_ids)
    to_resend = sent_noty_ids.from(sent_noty_ids.find_index(failed_notification_id) + 1)
    APN::Notification.update_all('sent_at = NULL', ['id IN (?)', to_resend])
  end

  def send_group_notifications
    if self.cert.nil? 
      raise APN::Errors::MissingCertificateError.new
      return
    end
    unless self.unsent_group_notifications.nil? || self.unsent_group_notifications.empty? 
      APN::Connection.open_for_delivery({:cert => self.cert}) do |conn, sock|
        unsent_group_notifications.each do |gnoty|
          gnoty.devices.find_each do |device|
            conn.write(gnoty.message_for_sending(device))
          end
          gnoty.sent_at = Time.now
          gnoty.save
        end
      end
    end
  end
  
  def send_group_notification(gnoty)
    if self.cert.nil? 
      raise APN::Errors::MissingCertificateError.new
      return
    end
    unless gnoty.nil?
      APN::Connection.open_for_delivery({:cert => self.cert}) do |conn, sock|
        gnoty.devices.find_each do |device|
          conn.write(gnoty.message_for_sending(device))
        end
        gnoty.sent_at = Time.now
        gnoty.save
      end
    end
  end
  
  def self.send_group_notifications
    APN::App.find_each &:send_group_notifications
  end          
  
  # Retrieves a list of APN::Device instnces from Apple using
  # the <tt>devices</tt> method. It then checks to see if the
  # <tt>last_registered_at</tt> date of each APN::Device is
  # before the date that Apple says the device is no longer
  # accepting notifications then the device is deleted. Otherwise
  # it is assumed that the application has been re-installed
  # and is available for notifications.
  # 
  # This can be run from the following Rake task:
  #   $ rake apn:feedback:process
  def process_devices
    if self.cert.nil?
      raise APN::Errors::MissingCertificateError.new
      return
    end
    APN::App.process_devices_for_cert(self.cert)
  end # process_devices
  
  def self.process_devices
    APN::App.find_each &:process_devices
  end
  
  def self.process_devices_for_cert(the_cert)
    puts "in APN::App.process_devices_for_cert"
    APN::Feedback.devices(the_cert).each do |device|
      if device.last_registered_at < device.feedback_at
        puts "device #{device.id} -> #{device.last_registered_at} < #{device.feedback_at}"
        device.destroy
      else 
        puts "device #{device.id} -> #{device.last_registered_at} not < #{device.feedback_at}"
      end
    end 
  end

end
