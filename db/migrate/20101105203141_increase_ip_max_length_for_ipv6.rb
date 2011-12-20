class IncreaseIpMaxLengthForIpv6 < ActiveRecord::Migration
  def self.up
    [:ideas, :comments].each do |table|
      change_column table, :ip, :string, :limit => 64
    end
  end

  def self.down
    [:ideas, :comments].each do |table|
      change_column table, :ip, :string, :limit => 16
    end
  end
end
