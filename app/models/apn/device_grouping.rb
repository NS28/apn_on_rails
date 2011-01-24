class APN::DeviceGrouping < APN::Base
  belongs_to :group, :class_name => 'APN::Group'
  belongs_to :device, :class_name => 'APN::Device'
  
  validates_presence_of :device_id, :group_id
  validate :same_app_id
  validates_uniqueness_of :device_id, :scope => :group_id
  
  def same_app_id
    unless group && device && group.app_id == device.app_id
      errors[:base] << 'device and group must belong to the same app'
    end
  end
end
