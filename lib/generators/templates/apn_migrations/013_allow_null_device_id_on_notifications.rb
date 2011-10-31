class AllowNullDeviceIdOnNotifications < ActiveRecord::Migration
  def self.up
    change_column(:apn_notifications, :device_id, :integer)
  end

  def self.down
    change_column(:apn_notifications, :device_id, :integer, :null => false)
  end
end
