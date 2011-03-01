class AddErrorResponseStatusCodeToApnNotification < ActiveRecord::Migration
  def self.up
    add_column(:apn_notifications, :error_response_status_code, :integer, :limit => 2)
  end

  def self.down
    remove_column(:apn_notifications, :error_response_status_code)
  end
end
