module APN
  class Base < ActiveRecord::Base # :nodoc:
    def self.table_name # :nodoc:
      to_s.gsub("::", "_").tableize
    end
  end
end
