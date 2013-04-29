# == Schema Information
#
# Table name: postal_codes
#
#  id   :integer          not null, primary key
#  code :string(255)
#  lat  :float
#  lon  :float
#

class PostalCode < ActiveRecord::Base
  
  def self.find_by_text(text)
    text =~ /\d{5}/
    PostalCode.find(:first, :conditions => { :code => $& })
  end
  
  def readonly?
    true
  end
  
end
