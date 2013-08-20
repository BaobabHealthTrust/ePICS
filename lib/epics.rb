module Epics
  
  def self.included(base)
    base.before_save :before_save_action
    base.before_create :before_create_action
  end
 
  def before_save_action
    self.creator = User.current.id if self.attributes.keys.include?("creator") and (self.creator.blank? || self.creator == 0)and User.current != nil
  end

  def before_create_action
    self.creator = User.current.id if self.attributes.keys.include?("creator") and (self.creator.blank? || self.creator == 0)and User.current != nil
    self.uuid = ActiveRecord::Base.connection.select_one("SELECT UUID() as uuid")['uuid'] if self.attributes.keys.include?("uuid")
  end
  
end
