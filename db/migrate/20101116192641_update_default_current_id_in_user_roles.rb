class UpdateDefaultCurrentIdInUserRoles < ActiveRecord::Migration
  def self.up
    old_default_current_id = 1
    Role.transaction do
      Role.find(:all, :conditions => { :authorizable_type => 'Current', :authorizable_id => old_default_current_id }).each do |role|
        role.authorizable_id = Current::DEFAULT_CURRENT_ID
        role.save!
      end
    end
  end

  def self.down
  end
end
