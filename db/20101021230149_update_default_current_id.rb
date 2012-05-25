class UpdateDefaultCurrentId < ActiveRecord::Migration
  def self.up
    # DEFAULT_CURRENT_ID was originally set to 1, which could cause havoc when the current
    # id sequence also returned 1. DEFAULT_CURRENT_ID is now set to -1, which fixes the
    # sequence issue.
    #
    # To support existing databases, this migration checks whether there is a current id = -1.
    # If not, it looks for a current named "Default Current", or a current with id = 1, and makes
    # it the default, updating its id and the current_id of any ideas that belong to it.
    
    begin
      Current.find Current::DEFAULT_CURRENT_ID
    rescue ActiveRecord::RecordNotFound
      default_current = Current.find_by_title('Default Current') || Current.find_by_id(1)
      if default_current
        old_default_current_id = default_current.id
        puts "Making Current##{old_default_current_id} (\"#{default_current.title}\") the default, with new id = #{Current::DEFAULT_CURRENT_ID}"
        Current.transaction do
          Current.connection.execute("update currents set id = #{Current::DEFAULT_CURRENT_ID} where id = #{old_default_current_id}")
          Current.connection.execute("update ideas set current_id = #{Current::DEFAULT_CURRENT_ID} where current_id = #{old_default_current_id}")
          change_column_default 'ideas', 'current_id', Current::DEFAULT_CURRENT_ID
        end
      end
    end
  end

  def self.down
  end
end
