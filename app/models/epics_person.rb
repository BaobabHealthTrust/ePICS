class EpicsPerson < ActiveRecord::Base
  set_primary_key :epics_person_id
  has_many :epics_stock_witnesses, :foreign_key => :epics_person_id, :conditions => {:voided => 0}


  def self.get_names(search_string)
    names = EpicsPerson.where("fname LIKE (?) OR lname LIKE (?)",
                                     "%#{search_string}%", "%#{search_string}%").map{|person|person.fname + " " + person.lname}


  end

  def self.get_authorisers(search_string)

    names = EpicsPerson.where("(fname LIKE (?) OR lname LIKE (?)) AND has_authority = TRUE",
                        "%#{search_string}%", "%#{search_string}%").map{|person|person.fname + " " + person.lname}

   return "<li></li><li>" + names.uniq.join("</li><li>") + "</li>"

  end

end
